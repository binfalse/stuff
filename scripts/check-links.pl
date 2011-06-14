#!/usr/bin/perl -w

# for more informations visit:
#
#     http://binfalse.de

use strict;
use LWP::UserAgent;
use XML::TreeBuilder;
use WebService::Validator::HTML::W3C;

# only if the url looks like ^(http(s)?:\/\/)?[^\/]*$domain it's recognized to
# be an internal link
my $domain = "example.org/";

my %visited = ();
my @tovisit = ( "http://".$domain );

my $browser = LWP::UserAgent->new;
$browser->timeout(10);
my $validator = WebService::Validator::HTML::W3C->new( detailed => 1 );

while (@tovisit)
{
	my $act = shift @tovisit;
	print "processing: ".$act." (todo:".@tovisit.")\n";
	
	my $response = $browser->get ($act);
	# our site avail !?
	if ($response->is_success)
	{
		#check w3c validity
		if ( $validator->validate($act) )
		{
			if ( $validator->is_valid )
			{
				validator ("ok", $validator->uri);
			}
			else
			{
				foreach my $error ( @{$validator->errors} )
				{
					validator ("error", $validator->uri, $error->msg, $error->line);
				}
			}
		}
		else
		{
			validator ("failed", $validator->validator_error);
		}
		
		
		my $iLinks = 0;
		my $oLinks = 0;
		
		my $xml = XML::TreeBuilder->new();
		$xml->parse ($response->decoded_content);
		foreach my $link ($xml->find_by_tag_name ('a'))
		{
			my $href = $link->attr ('href');
			next unless defined $href;
			
			# links this link to our domain?
			if ($href =~ m/^(http(s)?:\/\/)?[^\/]*$domain/i)
			{
				# intern
				# add to array if:
				#      not yet visited &&
				#      link ends with /     (all my content ends with / and i don't want to check .tgz and .png and so on...)
				push (@tovisit, $href) if (! defined $visited{$href} && $href =~ m/\/$/);
				$iLinks++;
			}
			else
			{
				# extern -> check if side is available
				my $res = $browser->get ($href)->code;
				failed ($act, $href, $res) if (! defined $visited{$href} && $href =~ m/^http/i && $res != 200);
				$oLinks++;
			}
			
			$visited{$href} = 1;
		}
		# for data analyzing
		loglinks ($iLinks, $oLinks);
	}
	else
	{
		failed ($act);
	}
}

sub failed
{
	my $site = shift;
	my $ext = shift;
	my $res = shift;
	open FAIL, ">>/tmp/check-links.fail";
	print FAIL $site . "\n" if (! defined $ext);
	print FAIL $site . " -> " . $ext . " (" . $res .")\n" if (defined $ext);
	close FAIL;
}

sub validator
{
	my $status = shift;
	my $site = shift;
	my $msg = shift;
	my $line = shift;
	open VAL, ">>/tmp/check-links.val";
	print VAL $status . ": " . $site . "\n" if (! defined $msg || ! defined $line);
	print VAL $status . ": " . $site . " -> " . $msg. " (" . $line .")\n" if (defined $msg && defined $line);
	close VAL;
}

sub loglinks
{
	my $intern = shift;
	my $extern = shift;
	open LOG, ">>/tmp/check-links.log";
	print LOG $intern . " " . $extern . "\n";
	close LOG;
}
