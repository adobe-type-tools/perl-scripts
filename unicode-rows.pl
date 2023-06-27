#!/usr/bin/perl

# Written by Dr. Ken Lunde (lunde@adobe.com)
# Senior Computer Scientist 2, Adobe Inc
# Version 2019-03-27
#
# This script accepts as its only argument a fully-qualified
# PostScript name for a CID-keyed font that includes a UTF-32
# (preferred) or UCS-2 CMap resource. The specified CMap resource must
# be in the current working directory, and a double hyphen must be
# used as the CIDFont/CMap separator (such as "KozMinPr6N-Regular--
# UniJIS2004-UTF32-H"). This script outputs to STDOUT a PostScript
# file that is expected to serve as input to the Distiller app to
# create a PDF file that is a visual representation of a Unicode CMap
# resource. The specified CIDFont and CMap resources must be
# accessible to the Distiller app, and the CIDFont resource must have
# the appropriate embedding permissions set, meaning that the
# /FontInfo dictionary must include /FSType with a value of 0, 4,
# or 8.
#
# Tool Dependencies: Adobe Acrobat Distiller
# Font Dependencies: SourceSansPro-Bold, SourceCodePro-ExtraLight,
# SourceCodePro-Semibold

($cidfont,$cmap) = $ARGV[0] =~ /^(.+)--(.+)$/;

if ($cmap =~ /UTF32/) {
  $len = 6;
  $len1 = 8;
} elsif ($cmap =~ /UCS2/) {
  $len = 2;
  $len1 = 4;
}

print STDOUT "%!\n\n";
print STDOUT "/T { /SourceSansPro-Bold 24 selectfont } bind def\n";
print STDOUT "/C { /SourceCodePro-ExtraLight 5 selectfont } bind def\n";
print STDOUT "/F { /$cidfont-$cmap 24 selectfont } bind def\n";
print STDOUT "/S { stringwidth pop 612 exch sub 2 div } bind def\n";
print STDOUT "/S1 { stringwidth pop 25.25 exch sub 2 div } bind def\n";
print STDOUT "/E { exch add } bind def\n";
print STDOUT "/M { moveto } bind def\n";
print STDOUT "/W { show } bind def\n";
print STDOUT "/SP { showpage } bind def\n";
print STDOUT "/BX { newpath 72 658 M 468 0 rlineto 0 -548 rlineto -468 0 rlineto closepath 1 setlinewidth stroke";
for ($x = 72; $x <= 540; $x += 29.25) {
  print STDOUT " newpath $x 668 M 0 -558 rlineto .5 setlinewidth stroke";
}
for ($y = 658; $y >= 110; $y -= 34.25) { # 34.25 was 29.25 ; 110 was 140; 658 was 608
  print STDOUT " newpath 62 $y M 478 0 rlineto .5 setlinewidth stroke";
}
print STDOUT " /SourceCodePro-Semibold 25.25 selectfont";

$x = 78.8755;

foreach $number (0 .. 15) {
  $new = sprintf("%01X",$number);
  print STDOUT " $x 663.03 M ($new) W";
  $x += 29.25;
}

$y = 635.78;

foreach $number (0 .. 15) {
  $new = sprintf("%01X",$number);
  print STDOUT " 52.25 $y M ($new) W";
  $y -= 34.25;
}
print STDOUT " } bind def\n\n";

undef $/;
open(CMAP,"<$cmap") or die "No dice! $cmap!\n";
$data = <CMAP>;
close(CMAP);
%cmap = &GetData($data); # Read in CMap file's information
%single_mappings = &StoreMappings($cmap{Mappings}) if exists $cmap{Mappings};

foreach $code (sort keys %single_mappings) {
  ($row) = $code =~ /^0x([0-9A-Fa-f]*)[0-9A-Fa-f][0-9A-Fa-f]$/;
  $row = hex $row;
  $rows{$row} = 1 if not exists $rows{$row};
}

$ros = "$cmap{Registry}-$cmap{Ordering}-$cmap{Supplement}";
$ro = "$cmap{Registry}-$cmap{Ordering}";

if ($ro eq "Adobe-GB1") {
  foreach $cid (1 .. 95, 7712 .. 7715, 22353, 22354) { $widths{$cid} = "P" }
  foreach $cid (814 .. 939, 7716, 22355 .. 22357) { $widths{$cid} = "H" }
  foreach $cid (0 .. 7716) { $supp{$cid} = "0" }
  foreach $cid (7717 .. 9896) { $supp{$cid} = "1" }
  foreach $cid (9897 .. 22126) { $supp{$cid} = "2" }
  foreach $cid (22127 .. 22352) { $supp{$cid} = "3" }
  foreach $cid (22353 .. 29063) { $supp{$cid} = "4" }
  foreach $cid (29064 .. 30283) { $supp{$cid} = "5" }
  foreach $cid (30284 .. 30571) { $supp{$cid} = "6" }
} elsif ($ro eq "Adobe-CNS1") {
  foreach $cid (1 .. 98, 17601) { $widths{$cid} = "P" }
  foreach $cid (13648 .. 13742, 17603) { $widths{$cid} = "H" }
  foreach $cid (0 .. 14098) { $supp{$cid} = "0" }
  foreach $cid (14099 .. 17407) { $supp{$cid} = "1" }
  foreach $cid (17408 .. 17600) { $supp{$cid} = "2" }
  foreach $cid (17601 .. 18845) { $supp{$cid} = "3" }
  foreach $cid (18846 .. 18964) { $supp{$cid} = "4" }
  foreach $cid (18965 .. 19087) { $supp{$cid} = "5" }
  foreach $cid (19088 .. 19155) { $supp{$cid} = "6" }
  foreach $cid (19156 .. 19178) { $supp{$cid} = "7" }
} elsif ($ro eq "Adobe-CNS2") {
  foreach $cid (0 .. 55879) { $supp{$cid} = "0" }
} elsif ($ro eq "Adobe-Japan1") {
  foreach $cid (1 .. 230, 9354 .. 9737, 15449 .. 15975, 20317 .. 20426) { $widths{$cid} = "P" }
  foreach $cid (231 .. 632, 8718, 8719, 12063 .. 12087) { $widths{$cid} = "H" }
  foreach $cid (9738 .. 9757) { $widths{$cid} = "Q" }
  foreach $cid (9758 .. 9778) { $widths{$cid} = "T" }
  foreach $cid (0 .. 8283) { $supp{$cid} = "0" }
  foreach $cid (8284 .. 8358) { $supp{$cid} = "1" }
  foreach $cid (8359 .. 8719) { $supp{$cid} = "2" }
  foreach $cid (8720 .. 9353) { $supp{$cid} = "3" }
  foreach $cid (9354 .. 15443) { $supp{$cid} = "4" }
  foreach $cid (15444 .. 20316) { $supp{$cid} = "5" }
  foreach $cid (20317 .. 23057) { $supp{$cid} = "6" }
  foreach $cid (23058 .. 23059) { $supp{$cid} = "7" }
} elsif ($ro eq "Adobe-Japan2") {
  foreach $cid (0 .. 6067) { $supp{$cid} = "0" }
} elsif ($ro eq "Adobe-Korea1") {
  foreach $cid (1 .. 100) { $widths{$cid} = "P" }
  foreach $cid (8094 .. 8190) { $widths{$cid} = "H" }
  foreach $cid (0 .. 9332) { $supp{$cid} = "0" }
  foreach $cid (9333 .. 18154) { $supp{$cid} = "1" }
  foreach $cid (18155 .. 18351) { $supp{$cid} = "2" }
} elsif ($ro eq "Adobe-KR") {
  foreach $cid (0, 119, 128, 132, 135, 136, 138 .. 147, 152 .. 155, 158 .. 169, 11451 .. 11877, 11895, 11923 .. 11925, 11932 .. 11976, 11978 .. 12107, 12151 .. 12234, 14238 .. 22479, 22690 .. 22896) { $widths{$cid} = "F" }
  foreach $cid (109, 170 .. 3000, 3053 .. 3056, 3059 .. 11450, 12108 .. 12150, 12237 .. 13500) { $widths{$cid} = "M" }
  foreach $cid (13501 .. 14237) { $widths{$cid} = "Z" }
  foreach $cid (12235, 12236) { $widths{$cid} = "Q" }
  foreach $cid (3057, 3058) { $widths{$cid} = "W" }
  foreach $cid (1 .. 108, 110 .. 118, 120 .. 127, 129 .. 131, 133, 134, 137, 148 .. 151, 156, 157, 3001 .. 3052, 11878 .. 11894, 11896 .. 11922, 11926 .. 11931, 11977, 22480 .. 22689) { $widths{$cid} = "P" }
  foreach $cid (0 .. 3058) { $supp{$cid} = "0" }
  foreach $cid (3059 .. 4636) { $supp{$cid} = "1" }
  foreach $cid (4637 .. 11450) { $supp{$cid} = "2" }
  foreach $cid (11451 .. 11730) { $supp{$cid} = "3" }
  foreach $cid (11731 .. 11877) { $supp{$cid} = "4" }
  foreach $cid (11878 .. 12234) { $supp{$cid} = "5" }
  foreach $cid (12235 .. 14237) { $supp{$cid} = "6" }
  foreach $cid (14238 .. 18857) { $supp{$cid} = "7" }
  foreach $cid (18858 .. 22479) { $supp{$cid} = "8" }
  foreach $cid (22480 .. 22896) { $supp{$cid} = "9" }
}

print STDERR "CIDFont: $cidfont CMap: $cmap ROS: $ros\n";

foreach $row (sort {$a <=> $b} keys %rows) {
  print STDERR "$row -> ";
  $row = sprintf("%0${len}X",$row);
  if (length($row) == 6) {
    if ($row =~ /^00(10)([0-9A-Fa-f][0-9A-Fa-f])$/) {
      $newrow = "U+$1" . $2 . "xx";
    } elsif ($row =~ /^000([1-9A-Fa-f])([0-9A-Fa-f][0-9A-Fa-f])$/) {
      $newrow = "U+$1" . $2 . "xx";
    } else {
      $row =~ /^0000([0-9A-Fa-f][0-9A-Fa-f])$/;
      $newrow = "U+" . $1 . "xx";
    }
  } else {
    $newrow = "U+" . $row . "xx";
  }
  print STDERR "$newrow\n";
  print STDOUT "T (Row $newrow: $cmap) S 698 M";
  print STDOUT " (Row $newrow: $cmap) W\n($ros) S 75 M\n($ros) W\nF\n";

  $count = 1;
  $x = 74;
  $y = 633.78;

  foreach $item (0 .. 255) {
    $cell = sprintf("%02X",$item);
    $newcode = "0x" . $row . $cell;
    if (exists $single_mappings{$newcode}) {
      print STDOUT "<$row$cell> S1 $x E $y M <$row$cell> W C";
      $savex = $x;
      $savey = $y;
      if (exists $widths{$single_mappings{$newcode}}) {
        $x -= 1;
        $y += 19.5;
        print STDOUT " $x $y M ($widths{$single_mappings{$newcode}}) W";
      }
      $x = $savex;
      $y = $savey;
      $x += 23.5;
      $y += 19.5;
      print STDOUT " $x $y M ($supp{$single_mappings{$newcode}}) W";
      $x = $savex;
      $y = $savey;
      $y -= 8;
      print STDOUT " ($single_mappings{$newcode}) S1 $x E $y";
      print STDOUT " M ($single_mappings{$newcode}) W F\n";
      $x = $savex;
      $y = $savey;
    }
    $x += 29.25;
    if ($count >= 16) {
      $y -= 34.25; # Was 29.25
      $x = 74;
      $count = 1;
    } else {
      $count++;
    }
  }
  print STDOUT "BX SP\n";
}

sub GetData ($) { # For extracting CMap information
  my ($cmapfile) = @_;
  my ($usecmap,$r,$o,$s,$name,$version,$uidoffset,$xuid,$wmode) = ("","","","","","","","","");
  my ($codespacerange,$notdefrange,$mappings) = ("","","");
  undef %data;

  ($usecmap) = $cmapfile =~ m{/([0-9a-zA-Z-]+)\s+usecmap};

  ($r,$o,$s) = $cmapfile =~ m{
    \s* /CIDSystemInfo \s+ \d+ \s+ dict \s+ dup \s+ begin
    \s* /Registry   \s+ \( (.+) \) \s+ def
    \s* /Ordering   \s+ \( (.+) \) \s+ def
    \s* /Supplement \s+ (\d+)      \s+ def
    \s* end \s+ def
  }msx;

  ($name) = $cmapfile =~ m{/CMapName\s+/([0-9a-zA-Z-]+)\s+def};
  ($version) = $cmapfile =~ m{/CMapVersion\s+(\d+(?:\.\d*))\s+def};
  ($uidoffset) = $cmapfile =~ m{(/UIDOffset\s+\d+)\s+def};
  ($xuid) = $cmapfile =~ m{/XUID\s+\[([0-9 ]+)\]\s+def};
  ($wmode) = $cmapfile =~ m{/WMode\s+([01])\s+def};
  ($codespacerange) = $cmapfile =~ m{
    (
      \d+
      \s+
      begincodespacerange
        .+
      endcodespacerange
      \s
    )
  }msx;
  ($notdefrange) = $cmapfile =~ m{
    (
      \s
      \d+
      \s+
      beginnotdefrange
        .+
      endnotdefrange
      \s
    )
  }msx;
  ($mappings) = $cmapfile =~ m{
    (
      \d+
      \s+
      begin(?:bf|cid)(?:char|range)
        .+
      end(?:bf|cid)(?:char|range)
    )
    \s+
    endcmap
  }msx;

  $data{UseCMap} = $usecmap if $usecmap;
  $data{Registry} = $r if $r;
  $data{Ordering} = $o if $o;
  $data{Supplement} = $s if $s or $s eq "0";
  $data{Name} = $name if $name;
  $data{Version} = $version if $version;
  $data{UIDOffset} = "$uidoffset def\n" if $uidoffset;
  $data{XUID} = $xuid if $xuid;
  $data{WMode} = $wmode if $wmode or $wmode eq "0";
  $data{CodeSpace} = $codespacerange if $codespacerange;
  $data{NotDef} = $notdefrange if $notdefrange;
  $data{Mappings} = $mappings if $mappings;

  return %data;
}

sub StoreMappings ($) {
  my ($mappings) = @_;
  my $processed = 0;

  ($bforcid) = $mappings =~ /begin(bf|cid)(?:char|range)/;
  @lines = split(/[\r\n]+/,$mappings);

  print STDERR "Reading CMap file into a lookup structure...";
  foreach $line (@lines) {
    $line = uc $line;
    if ($line =~ /^\s*<([\dA-F]+)>\s+(\d+)\s*$/) { # char
      $processed++;
      $hex = sprintf("%0${len1}X",hex($1));
      if (not defined $mapping{"0x" . $hex}) { # MODIFIED
        $mapping{"0x" . $hex} = $2; #MODIFIED
        $expanded++;
      } else {
        printf STDERR "Duplicate mapping at %0${len1}X!\n",hex($1);
      }
    } elsif ($line =~ /^\s*<([\dA-F]+)>\s+<([\dA-F]+)>\s+(\d+)\s*$/) { # range
      $processed++;
      $cid = $3;
      foreach $dec (hex($1) .. hex($2)) {
        $hex = sprintf("%0${len1}X",$dec);
        if (not defined $mapping{"0x" . $hex}) { # MODIFIED "0x" .
          $mapping{"0x" . $hex} = $cid; # MODIFIED
        } else {
          printf STDERR "Duplicate mapping at %0${len1}X!\n",$dec;
        }
        $expanded++;
        $cid++;
      }
    }
  }
  print STDERR "Done.\n";
  print STDERR "Processed $processed CMap lines into $expanded mappings.\n";
  return %mapping;
}
