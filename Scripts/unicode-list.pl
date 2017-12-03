#!/usr/bin/perl

# Written by Dr. Ken Lunde (lunde@adobe.com)
# Senior Computer Scientist 2, Adobe Systems Incorporated
# Version 12/03/2017
#
# This tool lists the Unicode code points in the specified OpenType
# font. By default, only the Unicode code points are listed, one per
# line, and if the OpenType font includes both a Format 4 (BMP-only
# UTF-16) and Format 12 (UTF-32) 'cmap' subtable, the latter is used.
#
# The "-g" command-line option will include the glyph names (for name-
# keyed fonts) or CIDs (for CID-keyed fonts) in a second column.
#
# The "-r" command-line option will turn the list of Unicode code
# points into ranges.
#
# If both command-line options are specified, the "-r" command-line
# option is ignored.
#
# Tool Dependencies: spot (AFDKO)

$addglyph = $range = $second = 0;
$data = "";

while ($ARGV[0]) {
    if ($ARGV[0] =~ /^-[huHU]/) {
        print STDERR "Usage: unicode-list.pl [-g|-r] <font>\n";
        exit;
    } elsif ($ARGV[0] =~ /^-[gG]/) {
        $addglyph = 1;
        shift;
    } elsif ($ARGV[0] =~ /^-[rR]/) {
        $range = 1;
        shift;
    } else {
        $file = "\"$ARGV[0]\"";
        shift;
    }
}

$range = 0 if $addglyph;

open(FILE,"spot -tcmap=11 $file |") or die "Cannot open $file input file!\n";

while(defined($line = <FILE>)) {
    chomp $line;
    if ($line =~ /=/) {
        if ($line =~ /^\[\s*(\d+)\]={.+(?:UTF-(16|32)).+}$/) {
            if ($2 == 16) {
                $utf16 = $1;
            } elsif ($2 == 32) {
                $utf32 = $1;
            }
        } elsif ($line =~ /^\[\s*(\d+)\]={Microsoft,Unicode\s.+(BMP|UCS[-]4).+}$/) {
            if ($2 eq "BMP") {
                $utf16 = $1;
            } elsif ($2 eq "UCS-4") {
                $utf32 = $1;
            }
        }
    }
}
close(FILE);

if (defined $utf32) {
    $index = $utf32;
    undef $utf16;
} else {
    $index = $utf16;
}

open(FILE,"spot -tcmap=7 -C$index $file |") or die "Cannot open $file input file!\n";

while(defined($line = <FILE>)) {
    chomp $line;
    if ($line =~ /^\[([0-9A-F]+)\]=<\\?(.+)>/) {
        $uni = $1;
        $glyph = $2;

        if ($range) {
            if (not $second) {
                $orig = $previous = $uni;
                $second = 1;
                next;
            }
            if (hex($uni) != hex($previous) + 1) {
                if ($orig eq $previous) {
                    $data .= "$orig\n";
                } else {
                    $data .= "$orig-$previous\n";
                }
                $orig = $previous = $uni;
            } else {
                $previous = $uni;
            }
        } elsif ($addglyph) {
            $data .= "$uni\t$glyph\n";
        } else {
            $data .= "$uni\n";
        }
    }
}

if ($range) {
    if ($orig eq $previous) {
        $data .= "$orig\n";
    } else {
        $data .= "$orig-$previous\n";
    }
}

print STDOUT $data;
