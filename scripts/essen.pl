#!/usr/bin/perl -w

use warnings;
use strict;
use LWP::UserAgent;

binmode STDOUT, ":utf8";

my $url = "http://meine-mensa.de/speiseplan_iframe";
my $mensa = 5;

my $browser = LWP::UserAgent->new(parse_head => 0);
$browser->timeout(10);

my $response = $browser->post ($url, ["selected_locations[]" => $mensa]);
my $content = $response->decoded_content ();
$content =~ s/\n//g;

while ($content =~ /<span style="font-weight: normal; font-size: 12px" class="counter_name">(.+?)<\/span>.+?<span.+?>(.+?)<\//gi)
{
	print $1.":\t".$2."\n";
}

