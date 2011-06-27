#!/usr/bin/perl -w
# see http://binfalse.de

use warnings;
use strict;
use Net::Proxy;

# for debugging set verbosity => dumping to stderr
# Net::Proxy->set_verbosity (1);

my $proxy = Net::Proxy->new (
	{
		in =>
		{
			# listen on 443
			type => 'dual', host => '0.0.0.0', port => 443,
			# if client asks for something direct to port 8080
			client_first => { type => 'tcp', port => 8080 },
			# if client waits for greetings direct to port 22
			server_first => { type => 'tcp', port => 22 },
			# wait for 2 seconds for questions by clients
			timeout => 2
		},
		# we don't use out...
		out => { type => 'dummy' }
	}
);

$proxy->register ();
Net::Proxy->mainloop ();
