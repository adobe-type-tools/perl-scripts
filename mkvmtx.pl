#!/usr/bin/perl 

# Written by Dr. Ken Lunde (lunde@adobe.com)
# Senior Computer Scientist 2, Adobe Systems Incorporated
# Version 12/14/2017

# This tool takes a CIDFont resource as its only command-line argument,
# along with a list of CIDs or CID ranges that correspond to full-width
# glyphs that rest on the Western baseline, such as Latin, Greek,
# Cyrillic, currency symbols, and other characters, as STDIN, and
# generates a 'vmtx' table override that can be included in a "features"
# file. The glyphs are mechanically centered along the Y-axis by using
# the top and bottom of the em-box as reference points, along with the
# top and bottom of their bounding boxes.
#
# Tool Dependencies: tx (AFDKO)

$file = $ARGV[0];
open(AFM,"tx -afm $file |") or die "Cannot open $file input file!\n";

$count = 0;

print STDERR "Loading CIDs ...";

while ($line = <STDIN>) {
  chomp $line;
  $count++;
  $line =~ s/^\s*(.*)\s*$/$1/;
  $line =~ s/\s+/ /;

  if ($line =~ /-/) {
    ($cidstart,$cidend) = split /-/, $line;
  } else {
    $cidstart = $line;
    $cidend = $cidstart;
  }
  foreach $cid ($cidstart .. $cidend) {
    $cidrange{$cid} = 1;
  }
}

print STDERR "Done\n";

# Adjust the values of the variables $ybottomlimit and $ytoplimit to
# correspond to the bottom and top of the em-box.

$ybottomlimit = -120;
$ytoplimit = 880;

$ycenter = ($ybottomlimit + $ytoplimit) / 2;

# Generate the 'vmtx' table override by mechanically-centering the
# specified CIDs along the Y-axis according to the em-box and glyph
# bounding boxes.

print STDOUT "table vmtx {\n";

while ($line = <AFM>) {
  if ($line =~ /^C.*/) {
    chomp $line;
    ($cid,$ymin,$ymax) = (split(/ /,$line))[7,11,13];
    if (exists $cidrange{$cid}) { 
      $halfy = ($ymax - $ymin) / 2;
      $yminnew = $ycenter - $halfy;
      $pushy = round($yminnew - $ymin);
      $pushy =~ s/^\+(\d+)/$1/;
      printf STDOUT "  VertOriginY \\$cid %s;\n",$ytoplimit - $pushy if $pushy !~ /^-?[0-4]$/;
    }
  }
}

print STDOUT "} vmtx;\n";

sub round {
  my ($arg) = @_;
  if ($arg =~ /\.[0-4]\d*/) {
    $arg =~ s/\.[0-4]\d*$//;
  } elsif ($arg =~ /\.[5-9]\d*/) {
    $arg =~ s/(\d+)\.[5-9]\d*$/$1 + 1/e;
  } return $arg;
}
