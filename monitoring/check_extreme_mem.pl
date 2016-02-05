#!/usr/bin/perl -w
#################################################
#
#     Monitor MEMORY of an extreme networks device
#     written by Martin Scharm
#       see http://binfalse.de
#
#################################################

use strict;
use Net::SNMP;
use Getopt::Long;
use Number::Format qw(format_bytes);

use lib "/usr/lib/nagios/plugins/";
use utils qw($TIMEOUT %ERRORS);


my $MEM_TOTAL = '1.3.6.1.4.1.1916.1.32.2.2.1.2.1';
my $MEM_FREE  = '1.3.6.1.4.1.1916.1.32.2.2.1.3.1';
my $MEM_SYS  = '1.3.6.1.4.1.1916.1.32.2.2.1.4.1';
my $MEM_USER  = '1.3.6.1.4.1.1916.1.32.2.2.1.5.1';

my $returnvalue = $ERRORS{"OK"};
my $returnstring = "";
my $returnsupp = "";

my $switch = undef;
my $community = undef;
my $help = undef;
my $warning = undef;
my $critical = undef;

Getopt::Long::Configure ("bundling");
GetOptions(
	'h' => \$help,
	'help' => \$help,
	's:s' => \$switch,
	'switch:s' => \$switch,
	'c:s' => \$critical,
	'critical:s' => \$critical,
	'w:s' => \$warning,
	'warn:s' => \$warning,
	'C:s' => \$community,
	'community:s' => \$community,
	'T:s' => \$TIMEOUT,
	'timeout:s' => \$TIMEOUT
);

sub nonum
{
  my $num = shift;
  if ( $num =~ /^(\d+\.?\d*)|(^\.\d+)$/ ) { return 0 ;}
  return 1;
}
sub print_usage
{
    print "Usage: $0 -s <SWITCH> -C <COMMUNITY-STRING> -w <WARNLEVEL> -c <CRITLEVEL> [-T <TIMEOUT>]\n\n";
    print "       <SWITCH>            the switch's hostname or ip address\n";
    print "       <COMMUNITY-STRING>  the community string as configured on the switch\n";
    print "       <WARNLEVEL>         the % of free mem that triggers a warning\n";
    print "       <CRITLEVEL>         the % of free mem that triggers a critical message\n";
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


# retrieving values

my $result = $session->get_request(-varbindlist => [$MEM_TOTAL,$MEM_FREE,$MEM_SYS,$MEM_USER] );
if (!defined($result))
{
   printf("ERROR: couldn't retrieve power supply values : %s.\n", $session->error);
   $session->close;
   exit $ERRORS{"CRITICAL"};
}
my $mem_total = $result->{$MEM_TOTAL};
my $mem_free = $result->{$MEM_FREE};
my $mem_sys = $result->{$MEM_SYS};
my $mem_user = $result->{$MEM_USER};


# generating the output
$returnvalue = $ERRORS{"WARNING"} if ($mem_free / $mem_total < $warning / 100);
$returnvalue = $ERRORS{"CRITICAL"} if ($mem_free / $mem_total < $critical / 100);

printf "free memory: %.2f%%", 100 * $mem_free / $mem_total;
printf "|total: %s; free: %s (%.2f%%); system: %s (%.2f%%); user: %s (%.2f%%)",
	format_bytes ($mem_total),
	format_bytes ($mem_free),
	100 * $mem_free / $mem_total,
	format_bytes ($mem_sys),
	100 * $mem_sys / $mem_total,
	format_bytes ($mem_user),
	100 * $mem_user / $mem_total;

exit $returnvalue;
