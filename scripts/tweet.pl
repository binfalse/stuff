#!/usr/bin/perl -w

###################################
#
#     written by Martin Scharm
#      see https://binfalse.de
#
###################################

use warnings;
use strict;
use Net::Twitter;
use Cwd 'abs_path';
use Encode;

my $CRED_FILE = abs_path($0) . ".credentials";
my $TOKEN_STR = "token";
my $TOKEN_SEC = "secret";

sub restore_cred
{
	my $file = $CRED_FILE;
	my $access_token = undef;
	my $access_token_secret = undef;
	
	open(CF,'<'.$file) or return ("", "");
	
	while (my $line = <CF>)
	{
		next if($line =~ /^\s*#/);
		next if($line !~ /^\s*\S+\s*=.*$/);
		
		my ($key,$value) = split(/=/,$line,2);
		
		$key   =~ s/^\s+//g;
		$key   =~ s/\s+$//g;
		$value =~ s/^\s+//g;
		$value =~ s/\s+$//g;
		
		$access_token = $value if ($key eq $TOKEN_STR);
		$access_token_secret = $value if ($key eq $TOKEN_SEC);
	}
	close(CF);
	return ($access_token, $access_token_secret);
}

sub save_cred
{
	my $file = $CRED_FILE;
	my $access_token = shift;
	my $access_token_secret = shift;
	
	if (!open(CF,'>'.$file))
	{
		print "could not save credentials to " . $CRED_FILE . "\n";
		return 0;
	}
	print CF $TOKEN_STR . "=" . $access_token . "\n";
	print CF $TOKEN_SEC . "=" . $access_token_secret . "\n";
	close(CF);
	return 1;
}

my $status = decode_utf8("@ARGV");
if (length $status > 140)
{
	print "you tried to send " . length ($status) . " characters, but only 140 are allowed...\n";
	exit 1;
}
if (length $status < 1)
{
	print "you tried to send 0 characters, thats no status brother...\n";
	exit 1;
}


my $nt = Net::Twitter->new(traits => ['API::REST', 'OAuth'], consumer_key => "KVgWlkFUWezK5AvJeR6GQ", consumer_secret => "CjuLw8Bh9OHG4DO9lnZnQK6w3UvoqNR1DB7oBwEgb44");

my ($access_token, $access_token_secret) = restore_cred();
if ($access_token && $access_token_secret)
{
	$nt->access_token($access_token);
	$nt->access_token_secret($access_token_secret);
}

unless ( $nt->authorized )
{
	print "Authorize this app at ", $nt->get_authorization_url, " and enter the PIN: ";
	chomp (my $pin = <STDIN>);
	my($access_token, $access_token_secret, $user_id, $screen_name) = $nt->request_access_token(verifier => $pin);
	if (save_cred($access_token, $access_token_secret))
	{
		print "successfull enabled this app! credentials are stored in: " . $CRED_FILE . "\n" 
	}
	else
	{
		die "failed\n";
	}
}

if ($nt->update({ status => $status }))
{
	print "updated your status!\n";
}
else
{
	print "failed\n";
	exit 1;
}
