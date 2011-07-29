#!/usr/bin/perl -w 
#################################################
#
#     Monitoring FLASH dirve of a CISCO catalyst
#     written by Martin Scharm
#       see http://binfalse.de
#
#################################################

use strict;
use Net::SNMP;
use Getopt::Long;

use lib "/usr/lib/nagios/plugins/";
use utils qw($TIMEOUT %ERRORS);

my $FLASHTABLE = '1.3.6.1.4.1.9.2.10';
my $FLASH_DESCR = $FLASHTABLE.'.4';
my $FLASH_SIZE = $FLASHTABLE.'.1';
my $FLASH_FREE = $FLASHTABLE.'.2';
my $FLASH_VPP = $FLASHTABLE.'.5';
my $FLASH_STATE = $FLASHTABLE.'.15';

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
my $flash_table = $session->get_table(-baseoid => $FLASH_DESCR);
if (!defined($flash_table))
{
   printf("ERROR: Description table : %s.\n", $session->error);
   $session->close;
   exit $ERRORS{"CRITICAL"};
}

my @flash_pools = keys %$flash_table;

for(my $pool = 1; $pool <= @flash_pools; $pool++)
{
	my $id = ((split(/\./, $flash_pools[$pool - 1])) [-1]);
	my $state = $FLASH_STATE.".".$id;
	my $size = $FLASH_SIZE.".".$id;
	my $free = $FLASH_FREE.".".$id;
	my $vpp = $FLASH_VPP.".".$id;
	my @oidlists = ($state, $size, $free, $vpp);
	my $resultat = $session->get_request(-varbindlist => \@oidlists);
	
	my $pfree = int (100 * $$resultat{$free} / $$resultat{$size});
	
	$returnvalue = $ERRORS{"WARNING"}
		if ($returnvalue != $ERRORS{"CRITICAL"} && ($pfree <= $warning));
	$returnvalue = $ERRORS{"CRITICAL"}
		if (($$resultat{$state} != 2 || $$resultat{$vpp} != 1 || $pfree <= $critical));
	my $val = "";
	my $val2 = "";
	if ($$resultat{$state} == 1) { $val = "busy"; }
	if ($$resultat{$state} == 2) { $val = "available"; }
	if ($$resultat{$vpp} == 1) { $val2 = "installed"; }
	if ($$resultat{$vpp} == 2) { $val2 = "missing"; }
	
	$returnstring .= " ".$$flash_table{$flash_pools[$pool - 1]}.": Size: ".$$resultat{$size}." Free: ".$$resultat{$free}." (".$pfree."%) Status: ".$val." VPP: ".$val2."!";
}

if ($returnvalue == $ERRORS{"CRITICAL"})
{
	print "CRITICAL: ".$returnstring."\n";
	exit $returnvalue;
}


if ($returnvalue == $ERRORS{"WARNING"})
{
	print "WARNING: ".$returnstring."\n";
	exit $returnvalue;
}

print "OK: ".$returnstring."\n";
exit $returnvalue;
