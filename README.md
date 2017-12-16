# Perl Scripts

This project includes an assortment of command-line Perl scripts that are useful for font development, and run in terminal apps, such as *Terminal* on macOS, and *Command Prompt* on Windows.

## Descriptions

### `cmap-tool.pl`

Run `cmap-tool.pl < STDIN > STDOUT` to compile (default) or decompile a CMap resource. The input file must already follow CMap resource syntax, and output is to STDOUT. Compiling means to efficiently use the `begincidchar`/`endcidchar` and `begincidrange`/`endcidrange` operators whereby the latter is used to efficiently represent contiguous code points whose CIDs are also contiguous, and to include in each declared `begincidchar`/`endcidchar` and `begincidrange`/`endcidrange` section no more than 100 records. The mappings are validated against the `begincodespacerange`/`endcodespacerange` section, and are also sorted according to it. When compiling a UTF-32 CMap resource, which is determined by the string "UTF32" being included in the CMap resource's name, corresponding UTF-8 and UTF-16 CMap resources are automatically generated.

`-e`: This option decompiles the `begincidchar`/`endcidchar` and `begincidrange`/`endcidrange` sections into a single `begincidchar`/`endcidchar` section. If a UTF-32 CMap resource is being decompiled, corresponding UTF-8 and UTF-16 CMap resources are not generated.

---

### `fdarray-check.pl`

Run `fdarray-check.pl <CID-keyed font> > STDOUT` to report to STDOUT the FDArray structure of a CID-keyed font&mdash;instantiated as a CIDFont resource, CFF resource, or OpenType/CFF font&mdash;that shows the ROS (/Registry, /Ordering, and /Supplement) and the name of each FDArray element, along with its index in parentheses, the CIDs and CID ranges that are assigned to it, and the total number of CIDs in parentheses. The CIDs are prefixed with a slash to explicitly indicate CIDs, as opposed to GIDs, which is useful when using the `-g` or `-gx` command-line options for many AFDKO tools, especially when GIDs do not equal CIDs in a particular font.

The following output example is from [*Ten Mincho Regular*](https://typekit.com/fonts/ten-mincho):

    Detected ROS: Adobe-Identity-0
    TenMincho-Regular-Alphabetic (0): /7434-/7444,/7452-/7477,/7484-/7509 (63)
    TenMincho-Regular-Dingbats (1): /0,/103,/112-/113,/118,/151,/183,/388-/389,/549,/554-/555,/562-/563,/565-/569,/572,/610-/612,/625-/629,/632,/636-/637,/640-/642,/645-/661,/663-/672,/675-/686,/688-/725,/813-/816,/911,/7391-/7433,/7445-/7451,/7478-/7483,/7510-/7520,/7921-/7944,/8197-/8206,/8236-/8242,/8270-/8279 (234)
    TenMincho-Regular-Emoji (2): /8193-/8196,/8280-/8283 (8)
    TenMincho-Regular-HWidth (3): /7911-/7920 (10)
    TenMincho-Regular-Italic (4): /8284-/9116 (833)
    TenMincho-Regular-Kana (5): /726-/812,/817-/910,/912-/915,/8207-/8235 (214)
    TenMincho-Regular-Kanji (6): /916-/7325,/7328-/7384,/7521-/7522 (6469)
    TenMincho-Regular-Proportional (7): /1-/102,/104-/111,/114-/117,/119-/150,/152-/182,/184-/387,/390-/548,/550-/553,/556-/561,/564,/570-/571,/573-/609,/613-/624,/630-/631,/633-/635,/638-/639,/643-/644,/662,/673-/674,/687,/7326-/7327,/7385-/7390,/7523-/7724,/7945-/7983,/7992-/8192 (1065)
    TenMincho-Regular-ProportionalJapanese (8): /7984-/7991 (8)
    TenMincho-Regular-Ruby (9): /7725-/7910,/8243-/8269 (213)

`-g`: This option suppresses the slash prefix for CIDs and CID ranges.

Tool Dependencies: `tx`

---

### `fix-fontbbox.pl`

Run `fix-fontbbox.pl <CIDFont resource> > STDOUT` to check and correct the /FontBBox array of a CIDFont resource. The original and corrected /FontBBox array values are reported to STDERR.

Tool Dependencies: `tx`

---

### `glyph-list.pl`

Run `glyph-list.pl <font> > STDOUT` to list the glyphs in the specified font, which can be a CIDFont resource, a name-keyed Type 1 font (aka PFA), UFO, or an 'sfnt' (TrueType or OpenType) font. Glyphs are listed as CIDs or glyph names, depending on whether the font is CID- or name-keyed. CIDs are prefixed with a slash.

`-g`: This option lists GIDs instead of CIDs or glyph names.  
`-r`: This option outputs the list of CIDs as ranges, or as a single GID range if the `-g` command-line option is also specified.  
`-s`: This option outputs a single line that uses a comma as a separator so that it can be repurposed, such as to be used as the argument of the `-g` or `-gx` command-line options that are supported by many AFDKO tools.

Tool Dependencies: `tx`

---

### `hintcidfont.pl`

Run `hintcidfont.pl <hinting parameter file> < STDIN > STDOUT` to apply hinting parameters to a CIDFont resource. A hinting parameter file (a sample hinting parameter file is provided at the end of the script, after the `__END__` declaration) serves as its only argument, and uses it to apply hinting parameters, such as alignment zones and stem values, to the header of a CIDFont resource that is specified as STDIN. A new CIDFont resource is written to STDOUT, which subsequently needs to be processed by the AFDKO `autohint` tool to apply the hinting parameters to the glyphs.

Special Note: The /FontName of each FDArray element as specified in the CIDFont resource header must be in a form that includes the /CIDFontName plus a unique identifier, such as `Dingbats`. For *Source Han Sans ExtraLight*, the /FontName would be `SourceHanSans-ExtraLight-Dingbats`. The hinting parameter file specifies only the unique identifier, such as `Dingbats` in the example.

---

### `mkicf.pl`

Run `mkicf.pl <CIDFont resource> < STDIN > STDOUT` to output to STDOUT a ready-to-use '[BASE](https://www.microsoft.com/typography/otspec/base.htm)' table override declaration that can be included in a "features" file that is used as input to the AFDKO `makeotf` tool as an argument of its `-ff` command-line option. A CIDFont resource serves as the only argument, a UTF-32 CMap resource is specified as STDIN, and these are used to calculate appropriate ICF (*Ideographic Character Face*) values. The output may look like the following:

    table BASE {
      HorizAxis.BaseTagList                 icfb  icft  ideo  romn;
      HorizAxis.BaseScriptList  DFLT  ideo   -78  838   -120  0,
                                hani  ideo   -78  838   -120  0,
                                kana  ideo   -78  838   -120  0,
                                latn  romn   -78  838   -120  0,
                                cyrl  romn   -78  838   -120  0,
                                grek  romn   -78  838   -120  0;
    
      VertAxis.BaseTagList                  icfb  icft  ideo  romn;
      VertAxis.BaseScriptList   DFLT  ideo  42    958   0     120,
                                hani  ideo  42    958   0     120,
                                kana  ideo  42    958   0     120,
                                latn  romn  42    958   0     120,
                                cyrl  romn  42    958   0     120,
                                grek  romn  42    958   0     120;
    } BASE;

`-k`: This option adds the 'hang' (hangul) script tag to the 'BASE' table override declaration.

Tool Dependencies: `tx`

---

### `mklocl.pl`

Run `mklocl.pl -i <input file> -o <output file> > STDOUT` to synthesizes a lookup for the '[locl](https://www.microsoft.com/typography/otspec/features_ko.htm#locl)' (_Localized Forms_) GSUB feature by specifying two region or language identifiers, whereby the input one is considered the default region or language in terms of which glyphs are encoded by default, and the output one represents a non-default region or language. Only those code points whose CIDs are different for the two specified regions or languages are included in the lookup declaration that is output to STDOUT. The input and output files, whose lines individually map eight-digit UTF-32 character codes to CIDs, and whose names must follow the pattern `utf32-<identifier>.map`, serve as the arguments of the `-i` and `-o` command-line options, respectively, and the region or language identifiers in their names are used for synthesizing the names of the lookup declarations. The input and output files must also be present in the current working directory.

This script must be run one time less than the number of supported regions or languages of the font. If a font supports the CN, TW, HK, JP, and KR regions, and if the default region is JP, then this script would be run four times as follows:

    % mklocl.pl -i utf32-jp.map -o utf32-cn.map > STDOUT
    % mklocl.pl -i utf32-jp.map -o utf32-tw.map >> STDOUT
    % mklocl.pl -i utf32-jp.map -o utf32-hk.map >> STDOUT
    % mklocl.pl -i utf32-jp.map -o utf32-kr.map >> STDOUT

This script was used for [_Source Han Sans_](https://github.com/adobe-fonts/source-han-sans/) and [_Source Han Serif_](https://github.com/adobe-fonts/source-han-serif/) development, and is therefore generally useful for Pan-CJK font development.

`-i`: This option specifies the file name that includes the UTF-32 to CID mappings of the input (default) region or language whose name must follow the pattern `utf32-<identifier>.map`.  
`-o`: This option specifies the file name that includes the UTF-32 to CID mappings of the output (non-default) region or language whose name must also follow the pattern `utf32-<identifier>.map`.

---

### `mkrange.pl`

Run `mkrange.pl < STDIN > STDOUT` to output a list of integer (default) or hexadecimal values as ranges of contiguous values using a hyphen as a separator. No sorting is performed, and integer values can be prefixed with a slash (the use of a slash prefix explicitly specifies CID values, as opposed to GID values, which is useful for CID-keyed font development).

`-h`: This option must be specified if the list is of hexadecimal values.  
`-s`: This option outputs a single line that uses a comma as a separator so that it can be repurposed, such as to be used as the argument of the `-g` or `-gx` command-line options that are supported by many AFDKO tools.

---

### `mkvmtx.pl`

Run `mkvmtx.pl <CIDFont resource> < STDIN > STDOUT` to output to STDOUT a ready-to-use '[vmtx](https://www.microsoft.com/typography/otspec/vmtx.htm)' table override declaration that can be included in a "features" file that is used as input to the AFDKO `makeotf` tool as an argument of its `-ff` command-line option. A CIDFont resource serves as the only argument, and STDIN is a list of CIDs and CID ranges that correspond to full-width glyphs that rest on the Western baseline, such as Latin, Greek, Cyrillic, currency symbols, and other characters. The specified CIDs are mechanically centered along the Y-axis by using the top and bottom of the em-box as reference points, along with the top and bottom of their bounding boxes. If a CID does not require adjustment, meaning that its glyph is already centered along the Y-axis, it is omitted from the output. Below is example output that uses CIDs 710 through 720:

    table vmtx {
      VertOriginY \710 889;
      VertOriginY \711 860;
      VertOriginY \712 847;
      VertOriginY \713 860;
      VertOriginY \714 860;
      VertOriginY \715 860;
      VertOriginY \716 860;
      VertOriginY \717 844;
      VertOriginY \719 871;
      VertOriginY \720 818;
    } vmtx;

Please see the [Resources](Resources) directory for the following pre-made lists of CIDs and CID ranges for Adobe's public ROSes: *vmtx.AC17* (Adobe-CNS1-7), *vmtx.AG15* (Adobe-GB1-5), *vmtx.AJ16* (Adobe-Japan1-6), and *vmtx.AK12* (Adobe-Korea1-2).

Tool Dependencies: `tx`

---

### `proof.pl`

Run `proof.pl <template font> <proofing font> < STDIN > STDOUT` to create a file that can be used to proof a font against a known or "template" font. STDIN is a list of CIDs (default), glyph names, or eight-digit hexadecimal UTF-32 character codes. STDOUT is a PostScript file that is expected to serve as input to the Adobe Acrobat Distiller app to create a PDF file. Each specified glyph, in the template and proofing font, is shown twice. The first instance is in the second and third columns in black, overlaid by the other glyph in gray. The second instance is in the fourth and fifth columns in black. The specified font resources must be accessible to the Adobe Acrobat Distiller app, and if a full-qualified PostScript font name is specified for CID-keyed fonts, the Unicode (UTF-32) CMap resource must also be accessible. Font resources must have the appropriate embedding permissions set, and for CIDFont resources, this means that the /FontInfo dictionary must include /FSType with a value of 0, 4, or 8.

`-t1`: This option must be specified if STDIN is a list of glyph names.  
`-uni`: This option must be specified if STDIN is a list of eight-digit hexadecimal UTF-32 character codes.

Tool Dependencies: Adobe Acrobat Distiller  
Font Dependencies: *Courier*

---

### `setsnap.pl`

Run `setsnap.pl < STDIN > STDOUT` to calculate highest-frequency (default) or optimal stem width values from one or more `stemHist`-generated stem width reports that are used to determine optimal hinting parameters.

`-o`: This option calculates optimal values based on point size range (default is 9 to 24 points) and resolution (default is 72 dpi).  
`-b`: This option specifies the bottom (lower) end of point size range, and is used only in conjunction with the `-o` command-line option.  
`-t`: This option specifies the top (upper) end of point size range, and is used only in conjunction with the `-o` command-line option.  
`-r`: This option specifies the resolution expressed in dpi, and is used only in conjunction with the `-o` command-line option.

---

### `sfnt-collection-check.pl`

Run `sfnt-collection-check.pl <sfnt collection> > STDOUT` with an 'sfnt' font collection&mdash;an OTC (OpenType/CFF Collection) or TTC (TrueType Collection)&mdash;as its only command-line argument to list the number of fonts (as determined by the number of '[name](https://www.microsoft.com/typography/otspec/name.htm)' table instances), a listing of which tables are completely unshared, partially shared, and completely shared, along with a list of each table and the number of their instances, sorted from highest to lowest.

The following output example is from the 142-font *SourceHanNotoCJK.ttc* Ultra OpenType/CFF Collection that is available in the [Source Han &amp; Noto CJK Mega/Ultra OTCs](https://github.com/adobe-fonts/source-han-super-otc/) project:

    Number of Fonts: 142
    Completely Unshared Tables: head, name
    Partially Shared Tables: BASE, CFF , GPOS, GSUB, OS/2, VORG, cmap, hhea, hmtx, maxp, post, vhea, vmtx
    Completely Shared Tables: SVG 
    head = 142
    name = 142
    OS/2 = 63
    hmtx = 21
    vhea = 21
    CFF  = 21
    hhea = 21
    vmtx = 21
    VORG = 21
    BASE = 19
    GPOS = 14
    cmap = 14
    GSUB = 10
    maxp = 2
    post = 2
    SVG  = 1

Tool Dependencies: `spot`

---

### `subr-check.pl`

Run `subr-check.pl <CFF> > STDOUT` to report the number of global (for name- and CID-keyed fonts) and local (for CID-keyed fonts only) subroutines that are present in the specified CFF or OpenType/CFF font, along with their sizes in bytes, and whether the number of subroutines exceeds architectural (64K - 3 = 65,533) or known implementation-specific (32K - 3 = 32,765) limits. Mac OS X Version 10.4 (aka, Tiger) and earlier, along with Adobe Acrobat Distiller Version 7.0 and earlier, are known implementations whose subroutine limit is 32K - 3 (32,765).

The following output example is from *Source Han Sans ExtraLight* that is available in the [Source Han Sans](https://github.com/adobe-fonts/source-han-sans/) project:

    Global Subroutines: 2342 (20941 bytes)
    Local Subroutines:
      FD=0: 3 (44 bytes)
      FD=1: 45 (519 bytes)
      FD=2: 2 (35 bytes)
      FD=3: 1100 (25297 bytes)
      FD=4: 26 (332 bytes)
      FD=5: 136 (1192 bytes)
      FD=7: 6 (75 bytes)
      FD=8: 4 (43 bytes)
      FD=9: 11 (145 bytes)
      FD=12: 18016 (280865 bytes)
      FD=13: 30000 (852990 bytes)
      FD=14: 144 (4570 bytes)
      FD=15: 247 (4813 bytes)
      FD=16: 13 (225 bytes)
      FD=18: 176 (3460 bytes)
    Total Subroutine Size: 1195546 bytes

Tool Dependencies: `tx`

---

### `unicode-list.pl`

Run `unicode-list.pl <font> > STDOUT` to list the Unicode code points that are supported by the '[cmap](https://www.microsoft.com/typography/otspec/cmap.htm)' table of the specified OpenType font. By default, only the Unicode code points are listed, one per line, and if the OpenType font includes both a Format 4 (BMP-only UTF-16) and Format 12 (UTF-32) 'cmap' subtable, the latter is used.

`-g`: This option includes the glyph names (for name-keyed fonts) or CIDs (for CID-keyed fonts) in a second column.  
`-r`: This option turns the list of Unicode code points into ranges, and is ignored if the `-g` command-line option is also specified.

Tool Dependencies: `spot`

---

### `unicode-rows.pl`

Run `unicode-rows.pl <CIDFont resource>--<UTF-32 CMap resource> > STDOUT` to create a visual representation of a Unicode (UTF-32 or UCS-2) CMap resource. This script accepts as its only argument a fully-qualified PostScript font name for a CID-keyed font that includes a UTF-32 (preferred) or UCS-2 CMap resource. The specified CMap resource must be in the current working directory, and a double hyphen must be used as the CIDFont/CMap separator (such as "KozMinPr6N-Regular--UniJIS2004-UTF32-H"). This script outputs to STDOUT a PostScript file that is expected to serve as input to the Adobe Acrobat Distiller app to create a PDF file that is a visual representation of the Unicode CMap resource. The specified CIDFont and CMap resources must be accessible to the Distiller app, and the CIDFont resource must have the appropriate embedding permissions set, meaning that its /FontInfo dictionary must include /FSType with a value of 0, 4, or 8.

Tool Dependencies: Adobe Acrobat Distiller  
Font Dependencies: *SourceSansPro-Bold*, *SourceCodePro-ExtraLight*, and *SourceCodePro-Semibold*

---

### `unrange.pl`

Run `unrange.pl < STDIN > STDOUT` to unwind a list of integer (default) or hexadecimal values, some of which may be expressed as ranges by using a hyphen as a separator, into a single value per line.

`-h`: This option must be specified if the list is of hexadecimal values.

---

## Installation

**macOS**: A version of Perl is already installed.  
**Windows**: You may need to install one of the versions available at [perl.org](http://www.perl.org/get.html).

## Dependencies

Some of the scripts may depend on particular tools being installed and appropriately configured to run on the command line. Such dependencies are stated in the comments section at the beginning of each script.

Here is a list of the locations from which you may need to get the extra tools and packages:

* [Adobe Font Development Kit for OpenType (AFDKO)](http://www.adobe.com/devnet/opentype/afdko.html)
    * spot
    * tx
* Adobe Acrobat Distiller

-----

## General usage information

1. Download the [ZIP package](https://github.com/adobe-type-tools/perl-scripts/archive/master.zip) and unzip it.
2.
 * All of the scripts can be run by simply typing `perl` followed by the file name of the script, such as `perl theScript.pl`.
 * If the script is in a different directory from which you are trying to run it, you will need to provide the full path to the script's file, such as `perl /Users/myself/foldername/theScript.pl`.
 * Some scripts may allow you to use options, or require that you provide input files. To learn how to use those scripts, open them in a text editor app (such as *TextEdit* on MacOS or *Notepad* on Windows) and read the documentation in the header of the file.

## Getting Involved

Send suggestions for changes to the Perl Scripts project maintainer, [Dr. Ken Lunde](mailto:lunde@adobe.com?subject=[GitHub]%20Perl%20Scripts), for consideration.
