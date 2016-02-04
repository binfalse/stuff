#!/usr/bin/perl -w
#################################################
#
#     Monitor TEMPERATURE of an extreme networks device
#     written by Martin Scharm
#       see http://binfalse.de
#
#################################################

use strict;
use Net::SNMP;
use Getopt::Long;
use Scalar::Util qw(looks_like_number);

use lib "/usr/lib/nagios/plugins/";
use utils qw($TIMEOUT %ERRORS);

my $TEMP_ALRM = '1.3.6.1.4.1.1916.1.1.1.7.0';
my $TEMP_CURR = '1.3.6.1.4.1.1916.1.1.1.8.0';


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

my $result = $session->get_request(-varbindlist => [$TEMP_CURR, $TEMP_ALRM] );
if (!defined($result))
{
   printf("ERROR: couldn't retrieve temperature values : %s.\n", $session->error);
   $session->close;
   exit $ERRORS{"CRITICAL"};
}
my $temp_alarm = $result->{$TEMP_ALRM};
my $temp_current = $result->{$TEMP_CURR};



# generating the output
print "Temperature " . ($temp_alarm != 2 ? "ALARM" : "OK");
print "|" . (looks_like_number $temp_current ? "current temperature: ${temp_current}°C; " : "") . "alarm status of overtemperature sensor: $temp_alarm (1=alarm,2=ok)";

exit $ERRORS{"OK"} unless $temp_alarm != 2;
exit $ERRORS{"CRITICAL"};
