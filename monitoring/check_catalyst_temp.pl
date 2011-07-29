#!/usr/bin/perl -w 
#################################################
#
#     Monitoring TEMPERATURE of a CISCO catalyst
#     written by Martin Scharm
#       see http://binfalse.de
#
#################################################

use strict;
use Net::SNMP;
use Getopt::Long;

use lib "/usr/lib/nagios/plugins/";
use utils qw($TIMEOUT %ERRORS);


my $TEMPTABLE = '1.3.6.1.4.1.9.9.13.1.3.1';
my $TEMP_POOLS = $TEMPTABLE.'.2';
my $TEMP_DEG = $TEMPTABLE.'.3';
my $TEMP_STATE = $TEMPTABLE.'.6';


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
    print "Usage: $0 -s <SWITCH> -C <COMMUNITY-STRING> -w <WARNLEVEL in °C> -c <CRITLEVEL in °C>\n";
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
if ($warning > $critical) 
{
	print "warning <= critical ! \n";
	print_usage();
	exit $ERRORS{"UNKNOWN"}
}

my ($session, $error) = Net::SNMP->session( -hostname  => $switch, -version   => 2, -community => $community, -timeout   => $TIMEOUT);

if (!defined($session)) {
   printf("ERROR opening session: %s.\n", $error);
   exit $ERRORS{"CRITICAL"};
}
my $temp_table = $session->get_table(-baseoid => $TEMP_POOLS);
if (!defined($temp_table))
{
   printf("ERROR: Description table : %s.\n", $session->error);
   $session->close;
   exit $ERRORS{"CRITICAL"};
}

my @mem_pools = keys %$temp_table;

for(my $pool = 1; $pool <= @mem_pools; $pool++)
{
	my $id = ((split(/\./, $mem_pools[$pool - 1])) [-1]);
	my $deg = $TEMP_DEG.".".$id;
	my $state = $TEMP_STATE.".".$id;
	my @oidlists = ($deg, $state);
	my $resultat = $session->get_request(-varbindlist => \@oidlists);
	
	$returnvalue = $ERRORS{"WARNING"}
		if ($returnvalue != $ERRORS{"CRITICAL"} && ($$resultat{$state} == 2 || $$resultat{$deg} >= $warning));
	$returnvalue = $ERRORS{"CRITICAL"}
		if (($$resultat{$state} != 1 && $$resultat{$state} != 2) || $$resultat{$deg} >= $critical);
	my $val = "";
	if ($$resultat{$state} == 1) { $val = "normal"; }
	if ($$resultat{$state} == 2) { $val = "warning"; }
	if ($$resultat{$state} == 3) { $val = "critical"; }
	if ($$resultat{$state} == 4) { $val = "shutdown"; }
	if ($$resultat{$state} == 5) { $val = "notPresent"; }
	if ($$resultat{$state} == 6) { $val = "notFunctioning"; }
	
	$returnstring .= " ".$$temp_table{$mem_pools[$pool - 1]}.": ".$$resultat{$deg}." Grad C ".$val."!";
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
