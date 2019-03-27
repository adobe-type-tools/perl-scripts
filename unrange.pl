#!/usr/bin/perl

# Written by Dr. Ken Lunde (lunde@adobe.com)
# Senior Computer Scientist 2, Adobe Inc.
# Version 2019-03-27
#
# This script uses STDIN and STDOUT, and simply unwinds a list of integer
# or hexadecimal values, some of which may be expressed as ranges by
# using a hyphen as a separator, into a single value per line. The "-h"
# command-line option must be specified if the input is hexadecimal.
#
# Tool Dependencies: None

$dohex = $len = 0;

while ($ARGV[0]) {
    if ($ARGV[0] =~ /^-[hH]/) {
        $dohex = 1;
        shift;
    } else {
        print STDERR "Invalid option: $ARGV[0]! Skipping...\n";
        shift;
    }
}

while(defined($line = <STDIN>)) {
    chomp $line;
    $line =~ s/\///g;
    if ($line =~ /-/) {
        ($begin,$end) = split(/-/,$line);
        if ($dohex) {
            $len = length $begin if not $len;
            foreach $num (hex($begin) .. hex($end)) {
                printf STDOUT "%0${len}X\n",$num;
            }
        } else {
            foreach $num ($begin .. $end) {
                print STDOUT "$num\n";
            }
        }
    } else {
        print STDOUT "$line\n";
    }
}
