#!/usr/bin/perl

# Written by Dr. Ken Lunde (lunde@adobe.com)
# Senior Computer Scientist 2, Adobe Systems Incorporated
# Version 02/28/2017
#
# This script uses STDIN and STDOUT, and simply unwinds a list of integer
# values, some of which may be expressed as ranges by using a hyphen as a
# separator, into a single value per line. This tool is useful when
# working with subset definition files for CIDFont resources.
#
# Tool Dependencies: None

while(defined($line = <STDIN>)) {
    chomp $line;
    $line =~ s/\///g;
    if ($line =~ /-/) {
        ($begin,$end) = split(/-/,$line);
        foreach $num ($begin .. $end) {
            print STDOUT "$num\n";
        }
    } else {
        print STDOUT "$line\n";
    }
}
