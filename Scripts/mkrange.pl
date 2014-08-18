#!/usr/bin/perl

# Written by Dr. Ken Lunde (lunde@adobe.com)
# Senior Computer Scientist, Adobe Systems Incorporated
# Version 08/18/2014
#
# This script takes a list of integer values as STDIN and outputs to
# STDOUT the same list, but as ranges of contiguous integer values
# using a hyphen as the separator. No sorting is performed, and the
# integer values can be prefixed with a slash (the use of a slash
# prefix explicitly species CID values, as opposed to GID values,
# which is useful for CID-keyed font development).
#
# The "-n" command-line option will output the integers and integer
# ranges as a single line that uses a comma as a separator.
#
# Tool Dependencies: None

$second = 0;
$prefix = "";

if ($ARGV[0] eq "-n") {
    $sep = ",";
} else {
    $sep = "\n";
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

if ($orig == $previous) {
    print STDOUT $prefix . $orig . "\n";
} else {
    print STDOUT $prefix . $orig . "-" . $prefix . $previous . "\n";
}
