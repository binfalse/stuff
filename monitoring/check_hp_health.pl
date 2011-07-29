#!/usr/bin/perl -w
###################################
#
#     HP ProLiant health Monitoring
#     written by Martin Scharm
#       see http://binfalse.de
#
#     tested with v8.60
#
###################################

use warnings;
use strict;
use lib '/usr/lib/nagios/plugins';
use utils qw(%ERRORS);
use Getopt::Long;

# binaries of ProLiant Support Pack
my $hpasmcli = "/sbin/hpasmcli";
my $hpacucli = "/usr/sbin/hpacucli";

# some of them might not be supported on your system, so disable them...
# hpasmcli -s SHOW DIMM
my $no_check_dimms = 0;
# hpasmcli -s SHOW FANS
my $no_check_fans = 0;
# hpasmcli -s SHOW POWERSUPPLY
my $no_check_powersupply = 0;
# hpasmcli -s SHOW SERVER
my $no_check_server = 0;
# hpasmcli -s SHOW TEMP
my $no_check_temp = 0;
# hpacucli ctrl all show config detail
my $no_check_ctrl = 0;
my $help = 0;

GetOptions (
	'no-check-dimms' => \$no_check_dimms,
	'no-check-fans' => \$no_check_fans,
	'no-check-powersupply' => \$no_check_powersupply,
	'no-check-server' => \$no_check_server,
	'no-check-temp' => \$no_check_temp,
	'no-check-ctrl' => \$no_check_ctrl,
	'help' => \$help,
	'h' => \$help);

my $dummy = undef;
my $err = "";
my $dbg = "";

$err .= "$hpasmcli not executeable\n" if (!-x $hpasmcli);
$err .= "$hpacucli not executeable\n" if (!-x $hpacucli);

if ($err || $help || ($no_check_dimms && $no_check_fans && $no_check_powersupply && $no_check_server && $no_check_temp && $no_check_ctrl))
{
	print $err . "\n\n" if ($err);
	print "PARAMETER:\n";
	print "\t--no-check-ctrl\tskip CONTROLLER checks\n";
	print "\t--no-check-server\tskip SERVER checks\n";
	print "\t--no-check-powersupply\tskip POWERSUPPLY checks\n";
	print "\t--no-check-temp\tskip TEMPERATURE checks\n";
	print "\t--no-check-dimms\tskip RAM checks\n";
	print "\t--no-check-fans\tskip FAN checks\n";
	print "\t--help\tprint this help\n";
	print "some of these checks might not be supported on your machine, so skip them as you like.\n";
	exit $ERRORS{'UNKNOWN'};
}



if (!$no_check_ctrl)
{
	my $ctrlerrs = 0;
	my $ctrldbg = "CTRL: ";
	my $slot = "";
	my $array = "";
	$dummy = "";
	open CMD, $hpacucli.' ctrl all show config |';
	while (<CMD>)
	{
		chomp;
		next if (m/^$/);
		if (m/Slot\s*(\d+)/) {$slot = $1; next;}
		if (m/array\s*(\S+)/) {$array = $1; next;}
		
		if (m/^\s*(\S)\S+drive\s(\S+).*\s+(\S+)\)/)
		{
			if ($3 ne "OK")
			{
				$ctrlerrs++;
				$ctrldbg .= "slot $slot array $array ".$1."d $2: $3; ";
			}
		}
	}
	if ($ctrlerrs)
	{
		$err .= "$ctrlerrs CTRL ERRs; ";
		$dbg .= $ctrldbg;
	}
	close CMD;
}

if (!$no_check_server)
{
	my $serrs = 0;
	my $sdbg = "SERVER: ";
	$dummy = "";
	open CMD, $hpasmcli.' -s "SHOW SERVER" |';
	while (<CMD>)
	{
		chomp if (m/./);
		if (m/^\S|^$/)
		{
			if ($dummy && $dummy =~ m/Processor\s*:/ && $dummy !~ m/Status\s*:\s*Ok/)
			{
				#print $dummy." \n";
				$dummy =~ m/^Processor\s*:\s*(\d+).*Status\s*:\s*(\S+)/;
				$sdbg .= "$1: $2; ";
				$serrs++;
			}
			$dummy = $_;
		}
		elsif (m/\s+\S/)
		{
			$dummy .= $_;
		}
	}
	if ($serrs)
	{
		$err .= "$serrs SERVER ERRs; ";
		$dbg .= $sdbg;
	}
	close CMD;
}

if (!$no_check_powersupply)
{
	my $pserrs = 0;
	my $psdbg = "POWERSUPPLY: ";
	$dummy = "";
	open CMD, $hpasmcli.' -s "SHOW POWERSUPPLY" |';
	while (<CMD>)
	{
		chomp if (m/./);
		if (m/^\S|^$/)
		{
			if ($dummy && $dummy =~ m/Present\s*:\s*Yes/ && $dummy !~ m/Condition\s*:\s*Ok/)
			{
				#print $dummy." \n";
				$dummy =~ m/^Power supply #(\d+).*Condition\s*:\s*(\S+)/;
				$psdbg .= "$1: $2; ";
				$pserrs++;
			}
			$dummy = $_;
		}
		elsif (m/\s+\S/)
		{
			$dummy .= $_;
		}
	}
	if ($pserrs)
	{
		$err .= "$pserrs POWERSUPPLY ERRs; ";
		$dbg .= $psdbg;
	}
	close CMD;
}

if (!$no_check_temp)
{
	my $terrs = 0;
	my $tdbg = "TEMP: ";
	$dummy = "";
	open CMD, $hpasmcli.' -s "SHOW TEMP" |';
	while (<CMD>)
	{
		chomp if (m/./);
		
		if (m/^#(\d+)\s*(\w+)\s*(\d+)C\/\d+F\s*(\d+)C\/\d+F\s*$/)
		{
			if ($3 > $4)
			{
				$tdbg .= "$2($1): ".$3."C (thresh ".$4."C); ";
				$terrs++;
			}
		}
	}
	if ($terrs)
	{
		$err .= "$terrs TEMP ERRs; ";
		$dbg .= $tdbg;
	}
	close CMD;
}

if (!$no_check_fans)
{
	$err .= "FAN checks not supported yet; ";
	$dbg .= "Skipping FAN-checks. Not supported unless HP tells me smth about the output..; ";
}

if (!$no_check_dimms)
{
	my $ramerrs = 0;
	my $ramerrsdbg = "RAM: ";
	$dummy = "";
	open CMD, $hpasmcli.' -s "SHOW DIMM" |';
	while (<CMD>)
	{
		chomp if (m/./);
		if (length > 1)
		{
			$dummy .= $_;
		}
		else
		{
			if ($dummy && $dummy =~ m/Present:\s*Yes/ && $dummy !~ m/Status:\s*OK$/)
			{
				$dummy =~ m/Cartridge #:\s*(\d)Processor #:\s*(\d+)Module #:\s*(\d+).*Status:\s*(\S*)/;
				$ramerrsdbg .= "$1/$2/$3: $4; ";
				$ramerrs++;
			}
			$dummy = "";
		}
	}
	if ($ramerrs)
	{
		$err .= "$ramerrs RAM ERRs; ";
		$dbg .= $ramerrsdbg;
	}
	close CMD;
}


if ($err)
{
	print $err . "|" . $dbg . "\n";
	exit $ERRORS{'CRITICAL'};
}

print "Everything's alright.|" . $dbg . "\n";
exit $ERRORS{'OK'};



