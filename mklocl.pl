#!/usr/bin/perl

# Written by Dr. Ken Lunde (lunde@adobe.com)
# Senior Computer Scientist 2, Adobe Inc.
# Version 2019-03-27
#
# This tool is useful for Pan-CJK font development in that it
# synthesizes a lookup for the 'locl' (Localized Forms) GSUB feature
# by specifying two region or language identifiers, whereby the input
# one is considered the default region or language in terms of which
# glyphs are encoded by default, and the output one is a non-default
# region or language. Only those code points whose CIDs are different
# for the two specified regions or languages are included in the
# lookup declaration. The input and output files, whose lines
# individually map eight-digit UTF-32 character codes to CIDs, and
# whose names must follow the pattern "utf32-<identifier>.map," serve
# as the arguments of the "-i" and "-o" command-line options,
# respectively, and the region or language identifiers are used for
# the names of the lookup declarations.

# Tool Dependencies: None

while ($ARGV[0]) {
    if ($ARGV[0] =~ /^-[huHU]/) {
        print STDERR "Usage: mklocl.pl -i <IN> -o <OUT> > <GSUB>\n";
        exit;
    } elsif ($ARGV[0] =~ /^-[iI]/) {
        shift;
        $input = $ARGV[0];
        shift;
    } elsif ($ARGV[0] =~ /^-[oO]/) {
        shift;
        $output = $ARGV[0];
        shift;
    }
}

# Extract the region or language identifiers from the input and output
# file names, which are used for the name of the lookup declaration

($input_locl) = $input =~ /utf32-(.+)\.map/;
($output_locl) = $output =~ /utf32-(.+)\.map/;

open(INPUT,"<$input") or  die "Error opening $input mapping file.\n";
open(OUTPUT,"<$output") or  die "Error opening $output mapping file.\n";

# Store the input mappings

while(defined($line = <INPUT>)) {
    chomp $line;
    ($uni,$cid) = $line =~ /^<([0-9A-F]{8})>\s+(\d+)$/;
    $mapping{$uni} = $cid;
}

# Compare the output mappings to the stored input mappings, and
# store any differences in the %cid2cid hash

while(defined($line = <OUTPUT>)) {
    chomp $line;
    ($uni,$cid) = $line =~ /^<([0-9A-F]{8})>\s+(\d+)$/;
    if ($mapping{$uni} != $cid) {
        $cid2cid{ $mapping{$uni} } = $cid;
    }
}

# Synthesize the lookup by using the %cid2cid hash

print STDOUT "lookup ${input_locl}2${output_locl} useExtension {\n";

foreach $cid (sort {$a <=> $b} keys %cid2cid) {
    print STDOUT "  substitute \\$cid by \\$cid2cid{$cid};\n";
}

print STDOUT "} ${input_locl}2${output_locl};\n\n";
