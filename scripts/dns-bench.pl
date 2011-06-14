#!/usr/bin/perl -w
use warnings;
use strict;

my $MAX=10000;
my @hosts = ("binfalse.de", "esmz-designz.com", "uni-halle.de", "0rpheus.net", "ixquick.com", "dict.tu-chemnitz.de", "bioinformatics.oxfordjournals.org", "download.oracle.com", "stackoverflow.com", "meet-unix.org", "jabber.cc.de", "perldoc.perl.org");

# openNIC germany 1&2 | google | my ISP | NS of uni-halle
my @servers = ("217.79.186.148", "178.63.26.173", "8.8.8.8", "172.16.20.53", "141.48.3.3");
my %dnsLookupTimes = ();

for (my $i = 0; $i < $MAX; $i++)
{
    my $host = $hosts[int(rand(@hosts))];
    print "try $host...\n";
    foreach my $server (@servers)
    {
        my $time = `dig \@$server $host | grep "Query time" | cut -f 4 -d " "`;
        $time =~ s/\n.*$//g;
        $dnsLookupTimes{$server} += $time;
    }
}

while ( my ($key, $value) = each (%dnsLookupTimes) )
{
    print $key." => ".($value)."\n";
}

