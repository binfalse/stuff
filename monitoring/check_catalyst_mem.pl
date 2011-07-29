#!/usr/bin/perl -w 
#################################################
#
#     Monitoring MEMORY of a CISCO catalyst
#     written by Martin Scharm
#      see http://binfalse.de
#
#################################################

use strict;
use Net::SNMP;
use Getopt::Long;

use lib "/usr/lib/nagios/plugins/";
use utils qw($TIMEOUT %ERRORS);


my $MEMTABLE = '1.3.6.1.4.1.9.9.48.1.1.1';
my $MEM_POOLS = $MEMTABLE.'.2';
my $MEM_VALID = $MEMTABLE.'.4';
my $MEM_USED = $MEMTABLE.'.5';
my $MEM_FREE = $MEMTABLE.'.6';


my $returnvalue = $ERRORS{"OK"};
my $returnstring = "";

my $switch = 	undef;
my $community = undef;
my $warning = undef;
my $critical = undef;
my $help = undef;

Getopt::Long::Configure ("bundling");
GetOptions(
	'h' => \$help,
	'help' => \$help,
	'c:s' => \$critical,
	'critical:s' => \$critical,
	'w:s' => \$warning,
	'warn:s' => \$warning,
	's:s' => \$switch,
	'switch:s' => \$switch,
	'C:s' => \$community,
	'community:s' => \$community
);

sub nonum
{
  my $num = shift;
  if ( $num =~ /^(\d+\.?\d*)|(^\.\d+)$/ ) { return 0 ;}
  return 1;
}
sub print_usage
{
    print "Usage: $0 -s <SWITCH> -C <COMMUNITY-STRING> -w <WARNLEVEL in \%free> -c <CRITLEVEL in \%free>\n";
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
if (!defined($warning) || !defined($critical))
{
	print "Need Warning- and Critical-Info!\n";
	print_usage();
	exit $ERRORS{"UNKNOWN"};
}
$warning =~ s/\%//g; 
$critical =~ s/\%//g;
if ( nonum($warning) || nonum($critical))
{
	print "Only numerical Values for crit/warn allowed !\n";
	print_usage();
	exit $ERRORS{"UNKNOWN"}
}
if ($warning < $critical) 
{
	print "warning >= critical ! \n";
	print_usage();
	exit $ERRORS{"UNKNOWN"}
}

my ($session, $error) = Net::SNMP->session( -hostname  => $switch, -version   => 2, -community => $community, -timeout   => $TIMEOUT);

if (!defined($session)) {
   printf("ERROR opening session: %s.\n", $error);
   exit $ERRORS{"CRITICAL"};
}
my $mem_table = $session->get_table(-baseoid => $MEM_POOLS);
if (!defined($mem_table))
{
   printf("ERROR: Description table : %s.\n", $session->error);
   $session->close;
   exit $ERRORS{"CRITICAL"};
}

my @mem_pools = keys %$mem_table;

for(my $pool = 1; $pool <= @mem_pools; $pool++)
{
	my $id = ((split(/\./, $mem_pools[$pool - 1])) [-1]);
	my $valid = $MEM_VALID.".".$id;
	my $used = $MEM_USED.".".$id;
	my $free = $MEM_FREE.".".$id;
	my @oidlists = ($valid, $used, $free);
	my $resultat = $session->get_request(-varbindlist => \@oidlists);
	
	my $pfree = int (100 * $$resultat{$free} / ($$resultat{$used} + $$resultat{$free}));
	
	$returnvalue = $ERRORS{"WARNING"}
		if ($returnvalue != $ERRORS{"CRITICAL"} && ($pfree <= $warning));
	$returnvalue = $ERRORS{"CRITICAL"}
		if ($$resultat{$valid} != 1 || $pfree <= $critical);
	
	my $val = ($$resultat{$valid} == 1) ? "valid" : "invalid";
	
	$returnstring .= " ".$$mem_table{$mem_pools[$pool - 1]}.": ".$val.", Used: ".$$resultat{$used}."B Free: ".$$resultat{$free}."B (".$pfree."%)!";
}

my $pdata = "|WARING <= ".$warning."%, CRITICAL <= ".$critical."%";

if ($returnvalue == $ERRORS{"CRITICAL"})
{
	print "CRITICAL: ".$returnstring.$pdata."\n";
	exit $returnvalue;
}


if ($returnvalue == $ERRORS{"WARNING"})
{
	print "WARNING: ".$returnstring.$pdata."\n";
	exit $returnvalue;
}

print "OK: ".$returnstring.$pdata."\n";
exit $returnvalue;
