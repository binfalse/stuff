#!/usr/bin/perl -w
#################################################
#
#     Monitor FANS of an extreme networks device
#     written by Martin Scharm
#       see http://binfalse.de
#
#################################################

use strict;
use Net::SNMP;
use Getopt::Long;

use lib "/usr/lib/nagios/plugins/";
use utils qw($TIMEOUT %ERRORS);

my $FANTABLE = '1.3.6.1.4.1.1916.1.1.1.9.1';
my $FAN_DEV = '1';
my $FAN_STATE = '2';
my $FAN_SPEED = '4';


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
my $fan_table = $session->get_table(-baseoid => $FANTABLE);
if (!defined($fan_table))
{
   printf("ERROR: Description table : %s.\n", $session->error);
   $session->close;
   exit $ERRORS{"CRITICAL"};
}

# building the hash with information on all the fans
my %fans = ();
foreach my $k (keys %$fan_table)
{
	my ($type,$id) = ((split(/\./, $k)) [-2,-1]);
	$fans{$id}{$type} = $$fan_table{$k};
}

# evaluating the fans
my $ok = 0;
my $nonok = 0;
foreach my $k (sort keys %fans)
{
	$returnsupp .= $fans{$k}{$FAN_DEV} . ": " . (($fans{$k}{$FAN_STATE} == 1) ? "OK" : "FAILED") . ($fans{$k}{$FAN_SPEED} ? " (" . $fans{$k}{$FAN_SPEED} . "RPM)" : "") . "; ";
	$ok++ if $fans{$k}{2} == 1;
	$nonok++ if $fans{$k}{2} != 1;
}

# generating the output
print "detected " . ($ok + $nonok) . " fans: " . $nonok . " are bad.";
print "|" . $returnsupp;

exit $ERRORS{"OK"} unless $nonok > 0;
exit $ERRORS{"CRITICAL"};

