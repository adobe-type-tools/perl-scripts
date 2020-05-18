#!/usr/bin/perl

# Written by Dr. Ken Lunde (lunde@adobe.com)
# Senior Computer Scientist 2, Adobe Inc.
# Version 2019-03-27
#
# This tool takes a hinting parameter file of a particular format as
# input (an example from Source Han Sans ExtraLight is provided at the
# end of this script), and uses it to apply hinting parameters, such
# as alignment zones and stem values, to the header of a CIDFont
# resource that is provided as STDIN. A new CIDFont resource is
# written to STDOUT, which then needs to be processed by the AFDKO
# autohint tool.
#
# Note that the FontName of each FDArray element must be in a form
# that includes the CIDFontName plus a unique identifier, such as
# Dingbats. For Source Han Sans ExtraLight, the FontName would be
# SourceHanSans-ExtraLight-Dingbats. The hinting parameter file
# specifies only the unique identifier, such as Dingbats.
#
# Tool Dependencies: None

$hintparam = $ARGV[0];

open(FILE,"<$hintparam") or die "Cannot open $hintparam input file!\n";

while(defined($line = <FILE>)) {
    chomp $line;
    if ($line =~ /^([A-Z][A-Za-z0-9]?.+)$/) {
        $hintdictname1 = $1;
    } elsif ($line =~ /(\/(?:BlueValues|BlueScale|OtherBlues|Std(?:H|V)W|StemSnap(?:H|V))\s+\[?\s*.+\s*\]?\s+def)/) {
        $hintdata{$hintdictname1} .= $1 . "\n";
    }
}

while(defined($line = <STDIN>)) {
    if ($line =~ /\/CIDFontName\s+\/(.+)\s+def/) {
        $cidfontname = $1;
        print STDERR "Detected CIDFontName: $cidfontname\n";
    } elsif ($line =~ /\/FontName \/${cidfontname}-(.+)\s+def/) {
        $hintdictname2 = $1;
        print STDERR "Modifying $hintdictname2 hinting parameters...\n";
    } elsif ($line =~ /\/Private \d+ dict dup begin/) {
        print STDOUT "/Private 15 dict dup begin\n";
        print STDOUT $hintdata{$hintdictname2};
        next;
    } elsif ($line =~/\/(?:Blue(?:Values|Scale|Fuzz)|(?:Family)?(?:Other)?Blues|Std(?:H|V)W|StemSnap(?:H|V)|RndStemUp)/ && exists $hintdata{$hintdictname2}) {
        next;
    }
    print STDOUT $line;
}

__END__
Alphabetic
/BlueValues [-13 0 526 540 726 739] def
/OtherBlues [-256 -243] def
/StdHW [33] def
/StdVW [37] def

AlphabeticDigits
/BlueValues [-14 0 704 716 726 738] def
/StdHW [34] def
/StdVW [38] def

Bopomofo
/BlueValues [-250 -250 1100 1100] def
/StdHW [22] def
/StdVW [22] def

Dingbats
/BlueValues [-1100 -1100 1900 1900] def
/StdHW [30] def
/StdVW [30] def
/StemSnapH [14 30] def
/StemSnapV [30 41] def

DingbatsDigits
/BlueValues [0 0 523 523 721 721] def
/StdHW [40] def
/StdVW [40] def

Generic
/BlueValues [-250 -250 1100 1100] def
/StdHW [40] def
/StdVW [40] def
/StemSnapH [40 120] def
/StemSnapV [40 120] def

HDingbats
/BlueValues [-250 -250 1100 1100] def
/StdHW [35] def
/StdVW [35] def

HHangul
/BlueValues [-250 -250 1100 1100] def
/StdHW [27] def
/StdVW [30] def

HKana
/BlueValues [-250 -250 1100 1100] def
/StdHW [30] def
/StdVW [30] def

HWidth
/BlueValues [-14 0 526 539 726 738] def
/OtherBlues [-236 -224] def
/StdHW [31] def
/StdVW [30] def
/StemSnapH [31 80] def
/StemSnapV [30 80] def

HWidthCJK
/BlueValues [-250 -250 1100 1100] def
/StdHW [31] def
/StdVW [30] def

HWidthDigits
/BlueValues [-12 0 704 717] def
/StdHW [26] def
/StdVW [36] def
/StemSnapH [26 34] def

Hangul
/BlueValues [-250 -250 1100 1100] def
/StdHW [30] def
/StdVW [33] def

Ideographs
/BlueValues [-250 -250 1100 1100] def
/StdHW [29] def
/StdVW [29] def

Kana
/BlueValues [-250 -250 1100 1100] def
/StdHW [30] def
/StdVW [30] def

Proportional
/BlueValues [-13 0 527 540 726 739] def
/OtherBlues [-257 -243 -210 -210] def
/StdHW [33] def
/StdVW [30] def
/StemSnapV [30 37] def

ProportionalCJK
/BlueValues [-250 -250 1100 1100] def
/StdHW [25] def
/StdVW [34] def
/StemSnapH [25 75 88] def
/StemSnapV [34 81] def

ProportionalDigits
/BlueValues [-13 0 726 740] def
/StdHW [26] def
/StdVW [35] def

VKana
/BlueValues [-250 -250 1100 1100] def
/StdHW [30] def
/StdVW [30] def
