#!/usr/bin/perl

# Written by Dr. Ken Lunde (lunde@adobe.com)
# Senior Computer Scientist 2, Adobe Systems Incorporated
# Version 12/14/2017

# This tool takes a CIDFont resource as input and a UTF-32 CMap
# resource as STDIN, calculates appropriate ICF (Ideographic
# Character Face) values, and outputs a ready-to-use 'BASE' table
# override section that can be used in a "features" file that is
# used as input to the AFDKO makeotf tool. The optional "-k" command-
# line option can be specified to insert the 'hang' (hangul) script
# tag.
#
# Tool Dependencies: tx (AFDKO)

use integer;

$data = $num = $count = $hang = $llx = $urx = $lly = $ury = 0;

while ($ARGV[0]) {
    if ($ARGV[0] =~ /^-[huHU]/) {
        print STDERR "Usage: mkicf.pl [-k] <CIDFont_Resource> < <UTF-32_CMap_Resource>\n";
        exit;
    } elsif ($ARGV[0] =~ /^-[kK]/) {
        print STDERR "Note: Inserting 'hang' script tag\n";
        $hang = 1;
        shift;
    } else {
        $file = $ARGV[0];
        shift;
    }
}

print STDERR "Storing CMap resource mappings into lookup structure...";
while (defined($line = <STDIN>)) {
  if ($data or $line =~ /begincid(?:char|range)/) {
    $data = 1;
  } else {
    next;
  }
  if ($line !~ /^\s*<([\da-fA-F]{8})>\s+(?:<([\da-fA-F]{8})>\s+)?(\d+)\s*$/) {
    next;
  } else {
    $begin = $1;
    if (not defined $2) {
      $end = $begin;
    } else {
      $end = $2;
    }
    $cid = $3;
  }
  foreach $char (hex($begin) .. hex($end)) {
    if ($char >= hex("00004E00") and $char <= hex("00009FFF") or
        $char >= hex("00003400") and $char <= hex("00004DBF") or
        $char >= hex("0000F900") and $char <= hex("0000FAD9") or
# Kana and hangul are generally excluded from the calculation, but
# should be uncommented as appropriate for kana- or hangul-only
# fonts:
#        $char >= hex("00003041") and $char <= hex("00003096") or
#        $char >= hex("000030A1") and $char <= hex("000030FA") or
#        $char >= hex("0000AC00") and $char <= hex("0000D7A3") or
        $char >= hex("00020000") and $char <= hex("0002FFFD")) {
      $code = sprintf("%08X",$char);
      $cid2code{$cid} = $code;
      $count++;
      $cid++;
    }
  }
}
print STDERR "Done.\n";

open(AFM,"tx -afm $file |") or die "Cannot open $file input file!\n";

print STDERR "Storing AFM records for ";
while (defined($line = <AFM>)) {
  chomp $line;
  if ($line =~ /^FontName/) {
    ($fontname) = $line =~ /^FontName\s+(.*)$/;
    print STDERR "\"$fontname\" CIDFont into lookup structure...";
  } elsif ($line =~ /^StartCharMetrics/) {
    while ($line !~ /^EndCharMetrics/) {
      chomp($line = <AFM>);
      ($width,$cid,$bbox,$a,$b,$c,$d) = $line =~ m{
        ^
          \s* C \s+ -?\d+ \s+ ; \s+
          W0X \s+ (\d+) \s+ ; \s+
          N \s+ (\d+) \s+ ; \s+
          B \s+ ((-?\d+) \s+ (-?\d+) \s+ (-?\d+) \s+ (-?\d+)) \s+ ; \s*
        $
      }x;
      if (exists $cid2code{$cid}) {
        $num++;
        if ($bbox ne "0 0 0 0") {
          $llx += $a;
          $lly += $b;
          $urx += $c;
          $ury += $d;
        }
      }
    }
  }
}
print STDERR "Done.\n";
close(AFM);

$left = $llx / $num;
$right = 1000 - ($urx / $num);
$bottom = 120 + ($lly / $num);
$top = 880 - ($ury / $num);

$result = ($left + $right + $bottom + $top) / 4;

$left = $result;
$right = 1000 - $result;
$bottom = -120 + $result;
$top = 880 - $result;

if ($hang) {
  print STDOUT <<EOF;
table BASE {
  HorizAxis.BaseTagList                 icfb  icft  ideo  romn;
  HorizAxis.BaseScriptList  DFLT  ideo   $bottom  $top   -120  0,
                            hang  ideo   $bottom  $top   -120  0,
                            hani  ideo   $bottom  $top   -120  0,
                            kana  ideo   $bottom  $top   -120  0,
                            latn  romn   $bottom  $top   -120  0,
                            cyrl  romn   $bottom  $top   -120  0,
                            grek  romn   $bottom  $top   -120  0;

  VertAxis.BaseTagList                  icfb  icft  ideo  romn;
  VertAxis.BaseScriptList   DFLT  ideo  $left    $right   0     120,
                            hang  ideo  $left    $right   0     120,
                            hani  ideo  $left    $right   0     120,
                            kana  ideo  $left    $right   0     120,
                            latn  romn  $left    $right   0     120,
                            cyrl  romn  $left    $right   0     120,
                            grek  romn  $left    $right   0     120;
} BASE;
EOF
} else {
  print STDOUT <<EOF;
table BASE {
  HorizAxis.BaseTagList                 icfb  icft  ideo  romn;
  HorizAxis.BaseScriptList  DFLT  ideo   $bottom  $top   -120  0,
                            hani  ideo   $bottom  $top   -120  0,
                            kana  ideo   $bottom  $top   -120  0,
                            latn  romn   $bottom  $top   -120  0,
                            cyrl  romn   $bottom  $top   -120  0,
                            grek  romn   $bottom  $top   -120  0;

  VertAxis.BaseTagList                  icfb  icft  ideo  romn;
  VertAxis.BaseScriptList   DFLT  ideo  $left    $right   0     120,
                            hani  ideo  $left    $right   0     120,
                            kana  ideo  $left    $right   0     120,
                            latn  romn  $left    $right   0     120,
                            cyrl  romn  $left    $right   0     120,
                            grek  romn  $left    $right   0     120;
} BASE;
EOF
}
