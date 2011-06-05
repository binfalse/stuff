#!/usr/bin/perl -w

###################################
#
#     written by Martin Scharm
#      see https://binfalse.de
#
###################################

use warnings;
use strict;
use Getopt::Long qw(:config no_ignore_case);
use lib '/usr/lib/nagios/plugins';
use utils qw(%ERRORS);

my $MOUNT = undef;
my $TYPE = undef;

sub how_to
{
	print "USAGE: $0\n\t-m MOUNTPOINT\twich mountpoint to check\n\t[-t TYPE]\toptionally check whether it's this kind of fs-type\n\n";
}

GetOptions (
		'm=s' => \ $MOUNT,
		'mountpoint=s' => \ $MOUNT,
		't=s' => \ $TYPE,
		'type=s' => \ $TYPE
	   );

unless (defined ($MOUNT))
{
	print "Please define mountpoint\n\n";
	how_to;
	exit $ERRORS{'CRITICAL'};
}

my $erg = `/bin/mount | /bin/grep $MOUNT`;

if ($erg)
{
	if (defined ($TYPE))
	{
		if ($erg =~ m/type $TYPE /)
		{
			print $MOUNT . " is mounted! Type is " . $TYPE . "\n";
			exit $ERRORS{'OK'};
		}
		else
		{
			print $MOUNT . " is mounted! But type is not " . $TYPE . "\n";
			exit $ERRORS{'WARNING'};
		}
	}
	print $MOUNT . " is mounted!\n";
	exit $ERRORS{'OK'};
}
else
{
	print $MOUNT . " is not mounted!\n";
	exit $ERRORS{'CRITICAL'};
}

