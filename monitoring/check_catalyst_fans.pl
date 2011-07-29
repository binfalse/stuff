#!/usr/bin/perl -w
#################################################
#
#     Monitoring FANS of a CISCO catalyst
#     written by Martin Scharm
#       see http://binfalse.de
#
#################################################

use strict;
use Net::SNMP;
use Getopt::Long;

use lib "/usr/lib/nagios/plugins/";
use utils qw($TIMEOUT %ERRORS);


my $FANTABLE = '1.3.6.1.4.1.9.9.13.1.4.1';
my $FAN_DESCR = $FANTABLE.'.2';
my $FAN_STATE = $FANTABLE.'.3';


my $returnvalue = $ERRORS{"OK"};
my $returnstring = "";

my $switch = 	undef;
my $community = undef;
my $help = undef;

Getopt::Long::Configure ("bundling");
GetOptions(
	'h' => \$help,
	'help' => \$help,
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
    print "Usage: $0 -s <SWITCH> -C <COMMUNITY-STRING>\n";
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


my ($session, $error) = Net::SNMP->session( -hostname  => $switch, -version   => 2, -community => $community, -timeout   => $TIMEOUT);

if (!defined($session)) {
   printf("ERROR opening session: %s.\n", $error);
   exit $ERRORS{"CRITICAL"};
}
my $fan_table = $session->get_table(-baseoid => $FAN_DESCR);
if (!defined($fan_table))
{
   printf("ERROR: Description table : %s.\n", $session->error);
   $session->close;
   exit $ERRORS{"CRITICAL"};
}

my @fan_pools = keys %$fan_table;

for(my $pool = 1; $pool <= @fan_pools; $pool++)
{
	my $id = ((split(/\./, $fan_pools[$pool - 1])) [-1]);
	my $state = $FAN_STATE.".".$id;
	my @oidlists = ($state);
	my $resultat = $session->get_request(-varbindlist => \@oidlists);
	
	$returnvalue = $ERRORS{"WARNING"}
		if ($returnvalue != $ERRORS{"CRITICAL"} && $$resultat{$state} == 2);
	$returnvalue = $ERRORS{"CRITICAL"}
		if (($$resultat{$state} != 1 && $$resultat{$state} != 2));
	my $val = "";
	if ($$resultat{$state} == 1) { $val = "normal"; }
	if ($$resultat{$state} == 2) { $val = "warning"; }
	if ($$resultat{$state} == 3) { $val = "critical"; }
	if ($$resultat{$state} == 4) { $val = "shutdown"; }
	if ($$resultat{$state} == 5) { $val = "notPresent"; }
	if ($$resultat{$state} == 6) { $val = "notFunctioning"; }
	
	$returnstring .= " ".$$fan_table{$fan_pools[$pool - 1]}.": ".$val."!";
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
