#!/usr/bin/perl -w
###############################
#
#   Havag departure scheduler
#
#   written by Martin Scharm
#     see http://binfalse.de
#
###############################
use warnings;
use strict;
use Encode;
require LWP::UserAgent;

# adresse an die die anfrage geht
my $SERVER = "http://83.221.237.42:20010/init/rtpi";
# zeichen vor der haltestelle
my @SENDPRE = ('63','00','01','6d','00','14','67','65','74','44','65','70','61','72','74','75','72','65','73','46','6f','72','53','74','6f','70','53','00');
# zeichen nach der haltestelle
my @SENDPOST = ('7A');
# regex um bahnen zu trennen
my @BSPLIT = ('56','74','00','07','5C','5B','73','74','72','69','6E','67','6C','00','00','00','0D','53','00','2E');
my @WSPLIT = ('53','00','2E');

my $script = $0;
my $stop = "@ARGV";

usage ($script, "keine Haltestelle angegeben!") if (!$stop);
usage ($script) if ($stop =~ /^-?-h/);

print "Frage $SERVER nach geplanten Stops für '$stop'...\n\n";
my $content = string_from_hex (@SENDPRE) . sprintf('%c', length (decode("utf8", $stop))) . $stop . string_from_hex (@SENDPOST);

my $ua = LWP::UserAgent->new;
$ua->timeout(10);
$ua->agent('binfalse-client/1.0 (binfalse.de)');

my $request = HTTP::Request->new('POST', $SERVER);
$request->content($content);
my $response = $ua->request ($request);

# kam 200 OK zurück?
if ($response->is_success)
{
	my %entries = ();
	my $linienlen = length "Linie";
	my $stationslen = length "Richtung";
	my $datelen = length "Zeit";
	
	# response in bahnen splitten
	my $splitter = string_from_hex(@BSPLIT);
	my @bahnen = split (/$splitter/s, $response->content);
	
	$splitter = string_from_hex (@WSPLIT);
	foreach my $b (@bahnen)
	{
		# bahn informationen extrahieren
		my @w = split(/$splitter/s, $b);
		if (@w > 3)
		{
			my @datum = split (/[.:]/, $w[2]);
			
			$linienlen = length $w[0] if (length $w[0] > $linienlen);
			$stationslen = length $w[1] if (length $w[1] > $stationslen);
			$datelen = length $datum[3].":".$datum[4] if (length $datum[3].":".$datum[4] > $datelen);
			
			$entries{$w[2].$w[0].$w[1]} = [$w[0], $w[1], $datum[3].":".$datum[4]];
		}
	}
	
	# in tabellenform ausgeben
	printf "%".$datelen."s   %".$linienlen."s   %-".$stationslen."s\n", "Zeit", "Linie", "Richtung";
	foreach my $e (sort keys %entries)
	{
		printf "%".$datelen."s   %".$linienlen."s   %-".$stationslen."s\n", $entries{$e}[2], $entries{$e}[0], $entries{$e}[1];
	}
}
else
{
	# da lief wohl etwas schief
	print $response->content . "\n";
	die $response->status_line;
}

# ähm, usage...
sub usage
{
	my $script = shift;
	my $msg = shift;
	print $msg."\n" if $msg;
	print "USAGE: $script HALTESTELLE\n";
	exit 1;
}

# einen string aus hex codes zusammen zaubern
sub string_from_hex
{
	my @code = @_;
	my $string = "";
	foreach my $c (@code)
	{
		$string .= sprintf('%c',hex($c));
	}
	return $string;
}
