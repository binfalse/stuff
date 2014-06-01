#!/usr/bin/perl -w
use warnings;
use strict;

# function to read an ics file
sub readCalendar
{
	my $event = {};
	my $calendar = {};
	my $keyword = "nothing";
	
	open (MYFILE, shift);
	while (<MYFILE>)
	{
		chomp;
		
		if ( $_ =~ /BEGIN:VEVENT/ )
		{
			# here starts an event -> empty the events hash
			$event = {};
			next;
		}
		
		if ( $_ =~ /END:VEVENT/ )
		{
			# end of an even -> store event in calendar
			$calendar->{$event->{'UID'}} = $event;
			next;
		}
		
		if ( $_ =~ /^[A-Z]/)
		{
			my @values = split(':', $_);
			$keyword = shift @values;
			# $cur = value for $keyword
			my $cur = join (':', @values);
			$cur =~ s/^\s+//;
			$cur =~ s/\s+$//;
			$event->{$keyword} = $cur;
		}
		else
		{
			# if this starts with smth ![A-Z] -> append the line to the last key
			my $cur = $_;
			$cur =~ s/^\s+//;
			$cur =~ s/\s+$//;
			$event->{$keyword} = $event->{$keyword} . $cur;
		}
	}
	close (MYFILE);
	return $calendar;
}

# use it
my $cal = readCalendar "/path/to/calendar";


# delete this.
foreach my $key (keys %$cal)
{
	print "FOUND EVENT:\n";
	foreach my $k (keys $cal->{$key})
	{
		print "$k => ".$cal->{$key}->{$k}."\n";
	}
	print "\n\n";
}
