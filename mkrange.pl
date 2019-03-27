#!/usr/bin/perl

# Written by Dr. Ken Lunde (lunde@adobe.com)
# Senior Computer Scientist 2, Adobe Inc.
# Version 2019-03-27
#
# This script takes a list of integer values as STDIN and outputs to
# STDOUT the same list, but as ranges of contiguous integer values
# using a hyphen as the separator. No sorting is performed, and the
# integer values can be prefixed with a slash (the use of a slash
# prefix explicitly specifies CID values, as opposed to GID values,
# which is useful for CID-keyed font development). Hexadecimal values
# are supported if the "-h" command-line option is specified.
#
# The "-s" command-line option will output the single values and
# ranges as a single line that uses a comma as a separator.
#
# Tool Dependencies: None

$second = $dohex = 0;
$prefix = "";
$sep = "\n";

while ($ARGV[0]) {
    if ($ARGV[0] =~ /^-[sS]/) {
        $sep = ",";
        shift;
    } elsif ($ARGV[0] =~ /^-[hH]/) {
        $dohex = 1;
        shift;
    } else {
        print STDERR "Invalid option: $ARGV[0]! Skipping...\n";
        shift;
    }
}


while(defined($line = <STDIN>)) {
    chomp $line;
    if ($line =~ m#^/#) {
        $line =~ s#^/##;
        $prefix = "/";
    }
    if (not $second) {
        $orig = $previous = $line;
        $second = 1;
        next;
    }
    if ($dohex) {
        if (hex($line) != hex($previous) + 1) {
            if ($orig eq $previous) {
                print STDOUT $prefix . $orig . $sep;
            } else {
                print STDOUT $prefix . $orig . "-" . $prefix . $previous . $sep;
            }
            $orig = $previous = $line;
        } else {
            $previous = $line;
        }
    } else {
        if ($line != $previous + 1) {
            if ($orig == $previous) {
                print STDOUT $prefix . $orig . $sep;
            } else {
                print STDOUT $prefix . $orig . "-" . $prefix . $previous . $sep;
            }
            $orig = $previous = $line;
        } else {
            $previous = $line;
        }
    }
}

if ($dohex) {
    if ($orig eq $previous) {
        print STDOUT $prefix . $orig . "\n";
    } else {
        print STDOUT $prefix . $orig . "-" . $prefix . $previous . "\n";
    }
} else {
    if ($orig == $previous) {
        print STDOUT $prefix . $orig . "\n";
    } else {
        print STDOUT $prefix . $orig . "-" . $prefix . $previous . "\n";
    }
}
