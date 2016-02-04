#!/usr/bin/perl -w
#################################################
#
#     Monitor POWER SUPPLY of an extreme networks device
#     written by Martin Scharm
#       see http://binfalse.de
#
#################################################

use strict;
use Net::SNMP;
use Getopt::Long;

use lib "/usr/lib/nagios/plugins/";
use utils qw($TIMEOUT %ERRORS);

my $POWER_OPERATIONAL = '1.3.6.1.4.1.1916.1.1.1.10.0';
my $POWER_VOLTAGE = '1.3.6.1.4.1.1916.1.1.1.20.0';
my $POWER_STATUS = '1.3.6.1.4.1.1916.1.1.1.21.0';
my $POWER_ALARM = '1.3.6.1.4.1.1916.1.1.1.22.0';
my $POWER_REDUNDANT_STATUS = '1.3.6.1.4.1.1916.1.1.1.11.0';
my $POWER_REDUNDANT_ALARM = '1.3.6.1.4.1.1916.1.1.1.12.0';

my $returnvalue = $ERRORS{"OK"};
my $returnstring = "";
my $returnsupp = "";

my $switch = undef;
my $community = undef;
my $help = undef;

Getopt::Long::Configure ("bundling");
GetOptions(
	'h' => \$help,
	'help' => \$help,
	's:s' => \$switch,
	'switch:s' => \$switch,
	'C:s' => \$community,
	'community:s' => \$community,
	'T:s' => \$TIMEOUT,
	'timeout:s' => \$TIMEOUT
);

sub print_usage
{
    print "Usage: $0 -s <SWITCH> -C <COMMUNITY-STRING> [-T <TIMEOUT>]\n\n";
    print "       <SWITCH>            the switch's hostname or ip address\n";
    print "       <COMMUNITY-STRING>  the community string as configured on the switch\n";
    print "       <TIMEOUT>           max time to wait for an answer, defaults to ".$TIMEOUT."\n"
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


# retrieving values

my $result = $session->get_request(-varbindlist => [$POWER_OPERATIONAL, $POWER_REDUNDANT_STATUS, $POWER_REDUNDANT_ALARM, $POWER_VOLTAGE, $POWER_STATUS, $POWER_ALARM] );
if (!defined($result))
{
   printf("ERROR: couldn't retrieve power supply values : %s.\n", $session->error);
   $session->close;
   exit $ERRORS{"CRITICAL"};
}
my $power_op = $result->{$POWER_OPERATIONAL};
my $power_redundant_state = $result->{$POWER_REDUNDANT_STATUS};
my $power_redundant_alarm = $result->{$POWER_REDUNDANT_ALARM};
my $power_voltage = $result->{$POWER_VOLTAGE};
my $power_status = $result->{$POWER_STATUS};
my $power_alarm = $result->{$POWER_ALARM};


# generating the output
$returnvalue = $ERRORS{"WARNING"} if ($power_redundant_state == 3 || $power_redundant_alarm != 2);
$returnvalue = $ERRORS{"CRITICAL"} if ($power_op != 1 || $power_alarm != 2 || $power_status != 2);

print "power supply is " . ($returnvalue == $ERRORS{"OK"} ? "ok" : "ERR");

printf "|power is%s operational%s - status: %s; voltage input is %s; redundant power supply is %s; redundant power is %s",
	($power_op != 1 ? " NOT" : ""), # NOT operational
	($power_alarm != 2 ? " and ALARMING!!" : ""), #power alarming
	($power_status == 1 ? "NOT PRESENT" : ($power_status == 2 ? "present and ok" : "PRESENT AND NOT OK")), #primary power present?
	($power_voltage == 1 ? "v110" : ($power_voltage == 2 ? "v220" : ($power_voltage == 3 ? "v48DC" : "unknown"))), # what voltage? supplemental only
	($power_redundant_state != 2 ? ($power_redundant_state != 1 ? "ERR" : "not existant") : "OK"), #what about the redundant supply
	($power_redundant_alarm != 2 ? "ALARMING" : "OK"); # is redundant alarming?

exit $returnvalue;
