#!/usr/bin/perl

# Written by Dr. Ken Lunde (lunde@adobe.com)
# Senior Computer Scientist 2, Adobe Systems Incorporated
# Version 12/14/2017
#
# This script accepts as STDIN a list of CIDs (for CIDFont resources),
# glyph names (for name-keyed fonts), or eight-digit hexadecimal
# UTF-32 character codes (for CID-keyed fonts that specify a UTF-32
# CMap resource). For glyph names, the "-t1" command-line option must
# be specified, and for eight-digit hexadecimal UTF-32 character
# codes, the "-uni" command-line option must be used.
#
# This script outputs to STDOUT a PostScript file that is expected to
# serve as input to the Distiller app to create a PDF file for
# proofing a font against a known or "template" font. Each specified
# glyph, in the template and proofing font, is shown twice. The first
# instance is in the second and third columns in black, overlaid by
# the other glyph in gray. The second instance is in the fourth and
# fifth columns in black. The specified template and proofing font
# resources must be accessible to the Distiller app, and if a
# full-qualified PostScript font name is specified for CID-keyed
# fonts, the (UTF-32) CMap resource must also be accessible. Font
# resources must have the appropriate embedding permissions set, and
# for CIDFont resources, this means that the /FontInfo dictionary must
# include /FSType with a value of 0, 4, or 8.
#
# Tool Dependencies: Adobe Acrobat Distiller
# Font Dependencies: Courier

$do_uni = $do_t1 = 0;

print STDOUT "\%!\n\n";
print STDOUT "/C { /Courier findfont 20 scalefont setfont } bind def\n";
print STDOUT "/G { 0.75 setgray } bind def /UG { 0.0 setgray } bind def\n";

@glyphs = <STDIN>;
chomp @glyphs;

while ($ARGV[0]) {
    if ($ARGV[0] =~ /^-t1$/) {
        $do_t1 = 1;
	shift;
    } elsif ($ARGV[0] =~ /^-uni$/) {
        $do_uni = 1;
        shift;
    } else {
        $tf = "/" . $ARGV[0];
        shift;
        $pf = "/" . $ARGV[0];
	shift;
    }
}

if ($do_t1 or $do_uni) {
  print STDOUT "/TF { $tf findfont 95 scalefont setfont } bind def\n";
  print STDOUT "/PF { $pf findfont 95 scalefont setfont } bind def\n";
  if ($do_t1) {
    foreach $glyph (@glyphs) {
      $glyph = "/" . $glyph;
    }
  }
} else {
  print STDOUT "/TF { $tf /CIDFont findresource 95 scalefont setfont } bind def\n";
  print STDOUT "/PF { $pf /CIDFont findresource 95 scalefont setfont } bind def\n";
  foreach $glyph (@glyphs) {
      if ($glyph =~ /[-]/) {
          $glyph =~ s#/##g;
          ($begin,$end) = split(/[-]/,$glyph);
          foreach $cid ($begin .. $end) {
              $allglyphs{$cid} = 1;
          }
      } else {
          $glyph =~ s#^/##;
          $allglyphs{$glyph} = 1;
      }
  }
  @glyphs = sort {$a <=> $b} keys %allglyphs;
}

$y = 700;
print STDOUT "\n";

foreach $glyph (@glyphs) {
  if ($do_uni) {
    $tempglyph = sprintf("U+%04X",hex $glyph);
    print STDOUT <<EOF;
C ($tempglyph) stringwidth pop 180 exch sub $y 30 add moveto ($tempglyph) show 200 $y moveto TF <$glyph> show 300 $y moveto PF <$glyph> show 400 $y moveto TF <$glyph> show 500 $y moveto PF <$glyph> show G 200 $y moveto <$glyph> show 300 $y moveto TF <$glyph> show UG
EOF

  } else {
    print STDOUT <<EOF;
C ($glyph) stringwidth pop 180 exch sub $y 30 add moveto ($glyph) show 200 $y moveto TF $glyph glyphshow 300 $y moveto PF $glyph glyphshow 400 $y moveto TF $glyph glyphshow 500 $y moveto PF $glyph glyphshow G 200 $y moveto $glyph glyphshow 300 $y moveto TF $glyph glyphshow UG
EOF
  }
  $y -= 95;
  if ($y < 20) {
    $y = 700;
    print STDOUT "showpage\n";
  }
}
print STDOUT "showpage\n";
