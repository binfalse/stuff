#!/usr/bin/perl -w
###################################
#
#     Monitor the UserBeanCounter
#     of OpenVZ vservers. This is
#     the way vservers tell it's
#     host about ressource issues.
#     written by Martin Scharm
#       see http://binfalse.de
#
###################################

use warnings;
use strict;
use lib "/usr/lib/nagios/plugins";
use utils qw(%ERRORS);

$ENV{'PATH'} = '/bin:/usr/bin:/usr/sbin/';
my $UBC = "/proc/user_beancounters";
my $UBC_CPY = "/tmp/nagios_user_beancounters";
my %CONTAINER = ();
my $RETURN = "";
my $RETURN_STAT = $ERRORS{'OK'};

if (! -e $UBC_CPY)
{
    if (! open IN, "<", $UBC )
    {
        print "could not read $UBC\n";
        exit $ERRORS{'CITICAL'};
    }
    if (! open OUT, ">", $UBC_CPY)
    {
        close IN;
        print "could not write $UBC_CPY\n";
        exit $ERRORS{'CITICAL'};
    }
    while ( my $line = <IN> )
    {
        print OUT $line;
    }
    close IN;
    close OUT;
    chmod 0600, $UBC_CPY;
    print "copied file first time\n";
    exit $ERRORS{'OK'};
}

my $original = parse ($UBC);
my $copy = parse ($UBC_CPY);

foreach my $key ( keys %$original )
{
    if (! $copy->{$key})
    {
        $CONTAINER{$key} .= "out of date;";
        $RETURN_STAT = $ERRORS{'WARNING'} if ($RETURN_STAT != $ERRORS{'CRITICAL'});
        next;
    }
    foreach my $key2 ( keys %{$original->{$key}} )
    {
        if ($original->{$key}->{$key2} > $copy->{$key}->{$key2})
        {
            $CONTAINER{$key} .= $key2 . "=>" . $original->{$key}->{$key2} . " (" . $copy->{$key}->{$key2} . "); ";
            $RETURN_STAT = $ERRORS{'CRITICAL'};
        }
        elsif ($original->{$key}->{$key2} < $copy->{$key}->{$key2})
        {
            $CONTAINER{$key} .= $key2 . "=>" . $original->{$key}->{$key2} . " (" . $copy->{$key}->{$key2} . " out of date); ";
            $RETURN_STAT = $ERRORS{'WARNING'} if ($RETURN_STAT != $ERRORS{'CRITICAL'});
        }
    }
}

foreach my $key ( keys %CONTAINER )
{
    my $zone = "";
    chomp ($zone = `/usr/sbin/vzctl exec $key hostname`) if (-e "/usr/sbin/vzctl" && -x "/usr/sbin/vzctl" && $key > 0);
    $RETURN .= "[" . ($zone ? $zone : $key) . "]: " . $CONTAINER{$key};
}

if ($RETURN)
{
    print keys( %CONTAINER ) . " container with failcounts:  " . $RETURN . "\n";
    exit $RETURN_STAT;
}

print "everything is fine..\n";
exit $ERRORS{'OK'};




sub parse
{
    my $file = shift;

    if (!open (FILE, "<".$file))
    {
        print "Could not open " . $file . "\n";
        exit $ERRORS{CRITICAL};
    }

    my $container = {};
    my $aktzone = -1;

    while (my $line = <FILE>)
    {
        next if ($line =~ m/^version/i);
        my @vals = split(/\s+/, $line);
        my $descr = scalar (@vals) > 7 ? $vals[2] : $vals[1];
        my $failcnt = scalar (@vals) > 7 ? $vals[7] : $vals[6];
        next if ($failcnt =~ m/fail/i);
        $aktzone = substr ($vals[1], 0, -1) if (scalar (@vals) == 8);
        $container->{$aktzone}->{$descr} = $failcnt;
    }

    close(FILE); 
    return $container;
}
