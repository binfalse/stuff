#!/usr/bin/perl -w
#################################################
#
#     Monitor FDB table of an extreme networks device
#     written by Martin Scharm
#       see http://binfalse.de
#
#################################################

use strict;
use Net::SNMP;
use Getopt::Long;
use lib "/usr/lib/nagios/plugins/";
use utils qw($TIMEOUT %ERRORS);


my $FDB_TABLE = '1.3.6.1.4.1.1916.1.16.4.1';
my $FDB_TABLE_MAC = '1';
my $FDB_TABLE_VLAN = '2';
my $FDB_TABLE_PORT = '3';
my $FDB_TABLE_STATUS = '4';

my $VLAN_TABLE = '1.3.6.1.4.1.1916.1.2.1.2.1';
my $VLAN_INDEX = '1';
my $VLAN_DESCR = '2';


my $returnvalue = $ERRORS{"OK"};
my $returnstring = "";
my $returnsupp = "";

my $switch = undef;
my $community = undef;
my $help = undef;
my $print = 0;
my $warn = 0;
my $expected_file = undef;

# the hash containing expected entries
my %EXPECTED_ENTRIES = ();
# keys are the macs
# every object in this hash has following fields
my $EXPECTED_PORT = 0;
my $EXPECTED_VLAN = 1;




Getopt::Long::Configure ("bundling");
GetOptions(
	'h' => \$help,
	'help' => \$help,
	's:s' => \$switch,
	'switch:s' => \$switch,
	'C:s' => \$community,
	'community:s' => \$community,
	'T:s' => \$TIMEOUT,
	'timeout:s' => \$TIMEOUT,
	'e:s' => \$expected_file,
	'expected:s' => \$expected_file,
	'W' => \$warn,
	'warn' => \$warn,
	'P' => \$print,
	'print' => \$print
);

sub display_mac
{
	my $mac = shift;
	$mac =~ s/^0x//g;
	$mac =~ s/[^:]{2}(?=[^\n ])/$&:/g;
	return $mac;
}
sub compareable_mac
{
	my $mac = shift;
	# replace colons
	$mac =~ s/://g;
	# replace leading 0x
	$mac =~ s/^0x//g;
	# all to lower
	return lc $mac;
}

sub print_usage
{
    print "Usage: $0 -s <SWITCH> -C <COMMUNITY-STRING> -e <EXPECTED> [-W|--warn] [-T <TIMEOUT>] [-P|--print]\n\n";
    print "       <SWITCH>            the switch's hostname or ip address\n";
    print "       <COMMUNITY-STRING>  the community string as configured on the switch\n";
    print "       <TIMEOUT>           max time to wait for an answer, defaults to ".$TIMEOUT."\n";
    print "       <EXPECTED>          expected entries: if those mac addresses appear they are expected\n";
    print "                           to be in that vlan and on that port, see --print\n";
    print "       -P | --print        displays fdb, you can use this as a template for the <EXPECTED> file\n";
    print "       -W | --warn         warn if an expected entry wasn't found\n";
}

# CHECKS
if ( defined($help) )
{
	print_usage();
	exit $ERRORS{"UNKNOWN"};
}
if ( !defined($switch) )
{
	print "Need Switch-Address!\n";
	print_usage();
	exit $ERRORS{"UNKNOWN"};
}
if ( !defined($community) )
{
	print "Need Community-String!\n";
	print_usage();
	exit $ERRORS{"UNKNOWN"};
}
if (!$print && !$expected_file)
{
	print "Need File containing expected entries!\n";
	print_usage();
	exit $ERRORS{"UNKNOWN"};
}

# read the file with expected entries
if ($expected_file)
{
	if (!open EXPECTED, $expected_file)
	{
		print "File $expected_file cannot be read!\n";
		print_usage();
		exit $ERRORS{"UNKNOWN"};
	}
	while (my $line = <EXPECTED>)
	{
		chomp $line;
		next if $line =~ m/^#/;
		my @fields = split "," , $line;
		if (@fields != 3)
		{
			print "File $expected_file cannot be read! Unrecognized entry: $line\n";
			print_usage();
			exit $ERRORS{"UNKNOWN"};
		}
		$EXPECTED_ENTRIES{compareable_mac($fields[0])} = [$fields[1], $fields[2]];
	}
	close EXPECTED;
}


my ($session, $error) = Net::SNMP->session( -hostname  => $switch, -version   => 2, -community => $community, -timeout   => $TIMEOUT);


# read vlan table
if (!defined($session)) {
   printf("ERROR opening session: %s.\n", $error);
   exit $ERRORS{"CRITICAL"};
}
my $vlan_table = $session->get_table(-baseoid => $VLAN_TABLE);
if (!defined($vlan_table))
{
   printf("ERROR: Description table : %s.\n", $session->error);
   $session->close;
   exit $ERRORS{"CRITICAL"};
}

# building the hash with information on all the fans
my %vlan = ();
foreach my $k (keys %$vlan_table)
{
	my ($type,$id) = ((split(/\./, $k)) [-2,-1]);
	$vlan{$id}{$type} = $$vlan_table{$k};
}



# read fdb table
if (!defined($session)) {
   printf("ERROR opening session: %s.\n", $error);
   exit $ERRORS{"CRITICAL"};
}
my $fdb_table = $session->get_table(-baseoid => $FDB_TABLE);
if (!defined($fdb_table))
{
   printf("ERROR: Description table : %s.\n", $session->error);
   $session->close;
   exit $ERRORS{"CRITICAL"};
}

# building the hash with information on all the fans
my %fdb = ();
foreach my $k (keys %$fdb_table)
{
	my $ks = substr $k, length ($FDB_TABLE) + 1;
	my $type = ((split(/\./, $ks)) [0]);
	my $id = substr $ks, 2;
	$fdb{$id}{$type} = $$fdb_table{$k} if ($type != $FDB_TABLE_MAC);
	$fdb{$id}{$type} = compareable_mac ($$fdb_table{$k}) if ($type == $FDB_TABLE_MAC);
}


my $discrepancies = 0;
my $nohit = 0;
$returnsupp .= "expected " . (keys %EXPECTED_ENTRIES) . " entries in fdb; ";

# print the fdb
if ($print)
{
	print "mac---------------port-vlan---\n";
	foreach my $k (sort keys %fdb)
	{
		print display_mac ($fdb{$k}{$FDB_TABLE_MAC}) . ",". $fdb{$k}{$FDB_TABLE_PORT} . "," . $vlan{$fdb{$k}{$FDB_TABLE_VLAN}}{$VLAN_DESCR} . "\n" if $fdb{$k}{$FDB_TABLE_MAC} && $fdb{$k}{$FDB_TABLE_PORT} && $fdb{$k}{$FDB_TABLE_VLAN};
	}
	exit $ERRORS{"UNKNOWN"};
}
else
{
	foreach my $k (sort keys %fdb)
	{
		if ($fdb{$k}{$FDB_TABLE_MAC} && $EXPECTED_ENTRIES{$fdb{$k}{$FDB_TABLE_MAC}})
		{
			my $mac = $fdb{$k}{$FDB_TABLE_MAC};
			# port correct?
			if ($EXPECTED_ENTRIES{$mac}[$EXPECTED_PORT] ne '*' && $EXPECTED_ENTRIES{$mac}[$EXPECTED_PORT] != $fdb{$k}{$FDB_TABLE_PORT})
			{
				$returnsupp .= "port of ".display_mac ($mac)." doesn't match: " . $EXPECTED_ENTRIES{$mac}[$EXPECTED_PORT] . " != " . $fdb{$k}{$FDB_TABLE_PORT} . "; ";
				$discrepancies++;
			}
			# vlan correct?
			if ($EXPECTED_ENTRIES{$mac}[$EXPECTED_VLAN] ne '*' && $EXPECTED_ENTRIES{$mac}[$EXPECTED_VLAN] ne $vlan{$fdb{$k}{$FDB_TABLE_VLAN}}{$VLAN_DESCR})
			{
				$returnsupp .= "port of ".display_mac ($mac)." doesn't match: " . $EXPECTED_ENTRIES{$mac}[$EXPECTED_VLAN] . " != " . $vlan{$fdb{$k}{$FDB_TABLE_VLAN}}{$VLAN_DESCR} . "; ";
				$discrepancies++;
			}
			$EXPECTED_ENTRIES{$mac}[$EXPECTED_PORT] = "found";
		}
	}
	
	foreach my $expected (sort keys %EXPECTED_ENTRIES)
	{
		if ($EXPECTED_ENTRIES{$expected}[$EXPECTED_PORT] ne "found")
		{
			$returnsupp .= display_mac ($expected)." not found; ";
			$nohit++;
		}
	}
}


if ($discrepancies == 0)
{
	if ($nohit == 0 || !$warn)
	{
		print "All is fine!|" . $returnsupp;
		exit $ERRORS{"OK"};
	}
	else
	{
		print $nohit." macs not found in fdb|" . $returnsupp;
		exit $ERRORS{"WARNING"};
	}
}
else
{
	print $discrepancies . " discrepancies in fdb";
	print " and ".$nohit." macs not found" if ($nohit != 0);
	print "|" . $returnsupp;
	exit $ERRORS{"CRITICAL"};
}

