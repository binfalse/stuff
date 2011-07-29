#!/usr/bin/perl -w 
#################################################
#
#     Monitoring FLASH drive of a CISCO catalyst
#     written by Martin Scharm
#      see http://binfalse.de
#
#################################################

use strict;
use Net::SNMP;
use Getopt::Long;

use lib "/usr/lib/nagios/plugins/";
use utils qw($TIMEOUT %ERRORS);

my $CPUTABLE = '1.3.6.1.4.1.9.9.109.1.1.1.1';
my $CPU_phys = $CPUTABLE.'.2';
my $CPU_5sec = $CPUTABLE.'.6';
my $CPU_1min = $CPUTABLE.'.7';
my $CPU_5min = $CPUTABLE.'.8';

my $returnvalue = $ERRORS{"OK"};
my $returnstring = "";

my $switch = 	undef;
my $community = undef;
my $warning = undef;
my @warning = undef;
my $critical = undef;
my @critical = undef;
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
    print "Usage: $0 -s <SWITCH> -C <COMMUNITY-STRING> -w <WARNLEVEL in 5s,1min,5min> -c <CRITLEVEL in 5s,1min,5min>\n";
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
@warning = split(/,/, $warning);
@critical = split(/,/, $critical);
if ((@warning != 3) || (@critical != 3))
{
	print "Need 3 warnings and 3 criticals, komma-seperated !\n";
	print_usage();
	exit $ERRORS{"UNKNOWN"};
}
for (my $i = 0; $i < 3; $i++)
{
	if ( nonum($warning[$i]) || nonum($critical[$i]))
	{
		print "Only numerical Values for crit/warn allowed !\n";
		print_usage();
		exit $ERRORS{"UNKNOWN"}
	}
	if ($warning[$i] > $critical[$i]) 
	{
		print "warning <= critical ! \n";
		print_usage();
		exit $ERRORS{"UNKNOWN"}
	}
}

my ($session, $error) = Net::SNMP->session( -hostname  => $switch, -version   => 2, -community => $community, -timeout   => $TIMEOUT);

if (!defined($session)) {
   printf("ERROR opening session: %s.\n", $error);
   exit $ERRORS{"CRITICAL"};
}
my $phys_table = $session->get_table(-baseoid => $CPU_phys);
if (!defined($phys_table))
{
   printf("ERROR: Description table : %s.\n", $session->error);
   $session->close;
   exit $ERRORS{"CRITICAL"};
}

my @phys_cpus = keys %$phys_table;

for(my $cpu = 1; $cpu <= @phys_cpus; $cpu++)
{
	my $id = ((split(/\./, $phys_cpus[$cpu - 1])) [-1]);
	my $s5 = $CPU_5sec.".".$id;
	my $m1 = $CPU_1min.".".$id;
	my $m5 = $CPU_5min.".".$id;
	my @oidlists = ($s5, $m1, $m5);
	my $resultat = $session->get_request(-varbindlist => \@oidlists);
	
	$returnvalue = $ERRORS{"WARNING"}
		if ($returnvalue != $ERRORS{"CRITICAL"} && ($$resultat{$s5} >= $warning[0] || $$resultat{$m1} >= $warning[1] || $$resultat{$m5} >= $warning[2]));
	$returnvalue = $ERRORS{"CRITICAL"}
		if (($$resultat{$s5} >= $critical[0] || $$resultat{$m1} >= $critical[1] || $$resultat{$m5} >= $critical[2]));
	
	$returnstring .= " CPU".$$phys_table{$phys_cpus[$cpu - 1]}.": ".$$resultat{$s5}."% ".$$resultat{$m1}."% ".$$resultat{$m5}."% !";
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
