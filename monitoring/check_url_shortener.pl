#!/usr/bin/perl -w
###################################
#
#     Monitoring URL Shortener
#     written by Martin Scharm
#       see http://binfalse.de
#
###################################
use warnings;
use strict;
use Getopt::Long;

# curl executable, you might need to change the path!?
my $curl = "/usr/bin/curl";


my $expect = "";
my $short = "";
my $respcode = 0;
my $respurl = "";
my $help = 0;

GetOptions (
	'short=s' => \$short,
	'expect=s' => \$expect,
	'help' => \$help,
	'h' => \$help);

if ($help || !-x $curl || !$short)
{
	print "$curl isn't executable...\n" unless -x $curl;
	print "need an URL (--short) to expand\n" unless $short;
	
	print "PARAMETERS:\n";
	print "\t--short \tshortened URL\n";
	print "\t--expect\texpected target redirection\n";
	print "\t--help  \tshow this msg\n";
	exit 3;
}

open CMD, "curl -s -I $short |";
while (<CMD>)
{
	if (m/^HTTP\S*\s+(\d+)/)
	{
		$respcode = $1;
		next;
	}
	if (m/^Location:\s+(\S+)\s*$/)
	{
		$respurl = $1;
		next;
	}
}
close CMD;

if ($respcode != 301)
{
	print "urgh, smth is wrong: response was $respcode, redirecting to $respurl\n";
	exit 2;
}

if ($expect && $respurl ne $expect)
{
	print "we are redirected with $respcode, but to $respurl, not as expected to $expect!?\n";
	exit 1;
}

print "redirecting works perfectly: $respcode -> $respurl\n";
exit 0;
