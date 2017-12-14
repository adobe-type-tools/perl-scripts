# Perl Scripts

This project includes an assortment of command-line Perl scripts that are useful for font development, and run in terminal apps, such as *Terminal* on macOS, and *Command Prompt* on Windows.

## Descriptions

### `cmap-tool.pl`

Run `cmap-tool.pl < STDIN > STDOUT` to compile (default) or decompile a CMap resource. The input file must already follow CMap resource syntax, and output is to STDOUT. Compiling means to efficiently use the `begincidchar`/`endcidchar` and `begincidrange`/`endcidrange` operators whereby the latter is used to efficiently represent contiguous code points whose CIDs are also contiguous, and to include in each declared `begincidchar`/`endcidchar` and `begincidrange`/`endcidrange` section no more than 100 records. The mappings are validated against the `begincodespacerange`/`endcodespacerange` section, and are also sorted according to it. When compiling a UTF-32 CMap resource, which is determined by the string "UTF32" being included in the CMap resource's name, corresponding UTF-8 and UTF-16 CMap resources are automatically generated.

`-e`: This option decompiles the `begincidchar`/`endcidchar` and `begincidrange`/`endcidrange` sections into a single `begincidchar`/`endcidchar` section. If a UTF-32 CMap resource is being decompiled, corresponding UTF-8 and UTF-16 CMap resources are not generated.

---

### `fdarray-check.pl`

Run `fdarray-check.pl <CID-keyed font> > STDOUT` to report to STDOUT the FDArray structure of a CID-keyed font&mdash;instantiated as a CIDFont resource, CFF resource, or OpenType/CFF font&mdash;that shows the ROS (/Registry, /Ordering, and /Supplement) and the name of each FDArray element, along with its index in parentheses, the CIDs and CID ranges that are assigned to it, and the total number of CIDs in parentheses. The CIDs are prefixed with a slash to explicitly indicate CIDs, as opposed to GIDs, which is useful when using the `-g` or `-gx` command-line options for many AFDKO tools, especially when GIDs do not equal CIDs in a particular font.

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

Run `mkicf.pl <CIDFont Resource> < STDIN > STDOUT` to output to STDOUT a ready-to-use 'BASE' table override declaration that can be included in a "features" file that is used as input to the AFDKO `makeotf` tool as an argument of its `-ff` command-line option. A CIDFont resource serves as the only argument, a UTF-32 CMap resource is specified as STDIN, and these are used to calculate appropriate ICF (*Ideographic Character Face*) values. The output may look like the following:

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

### `mkrange.pl`

Run `mkrange.pl < STDIN > STDOUT` to output a list of integer (default) or hexadecimal values as ranges of contiguous values using a hyphen as a separator. No sorting is performed, and integer values can be prefixed with a slash (the use of a slash prefix explicitly specifies CID values, as opposed to GID values, which is useful for CID-keyed font development).

`-h`: This option must be specified if the list is of hexadecimal values.  
`-s`: This option outputs a single line that uses a comma as a separator so that it can be repurposed, such as to be used as the argument of the `-g` or `-gx` command-line options that are supported by many AFDKO tools.

---

### `mkvmtx.pl`

Run `mkvmtx.pl <CIDFont resource> < STDIN > STDOUT` to output to STDOUT a ready-to-use 'vmtx' table override declaration that can be included in a "features" file that is used as input to the AFDKO `makeotf` tool as an argument of its `-ff` command-line option. A CIDFont resource serves as the only argument, and STDIN is a list of CIDs and CID ranges that correspond to full-width glyphs that rest on the Western baseline, such as Latin, Greek, Cyrillic, currency symbols, and other characters. The specified CIDs are mechanically centered along the Y-axis by using the top and bottom of the em-box as reference points, along with the top and bottom of their bounding boxes. If a CID does not require adjustment, meaning that its glyph is already centered along the Y-axis, it is omitted from the output. Below is example output that uses CIDs 710 through 720:

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

Run `proof.pl <template-font> <proofing-font> < STDIN > STDOUT` to create a file that can be used to proof a font against a known or "template" font. STDIN is a list of CIDs (default), glyph names, or eight-digit hexadecimal UTF-32 character codes. STDOUT is a PostScript file that is expected to serve as input to the Adobe Acrobat Distiller app to create a PDF file. Each specified glyph, in the template and proofing font, is shown twice. The first instance is in the second and third columns in black, overlaid by the other glyph in gray. The second instance is in the fourth and fifth columns in black. The specified font resources must be accessible to the Adobe Acrobat Distiller app, and if a full-qualified PostScript font name is specified for CID-keyed fonts, the Unicode (UTF-32) CMap resource must also be accessible. Font resources must have the appropriate embedding permissions set, and for CIDFont resources, this means that the /FontInfo dictionary must include /FSType with a value of 0, 4, or 8.

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

### `subr-check.pl`

Run `subr-check.pl <CFF> > STDOUT` to report the number of global (for name- and CID-keyed fonts) and local (for CID-keyed fonts only) subroutines that are present in the specified CFF or OpenType/CFF font, along with their sizes in bytes, and whether the number of subroutines exceeds architectural (64K - 3 = 65,533) or known implementation-specific (32K - 3 = 32,765) limits. Mac OS X Version 10.4 (aka, Tiger) and earlier, along with Adobe Acrobat Distiller Version 7.0 and earlier, are known implementations whose subroutine limit is 32K - 3 (32,765).

Tool Dependencies: `tx`

---

### `unicode-list.pl`

Run `unicode-list.pl <font> > STDOUT` to list the Unicode code points that are supported by the 'cmap' table of the specified OpenType font. By default, only the Unicode code points are listed, one per line, and if the OpenType font includes both a Format 4 (BMP-only UTF-16) and Format 12 (UTF-32) 'cmap' subtable, the latter is used.

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

## General usage information
-----
1. Download the [ZIP package](https://github.com/adobe-type-tools/perl-scripts/archive/master.zip) and unzip it.
2. 
 * All of the scripts can be run by simply typing `perl ` followed by the file name of the script, such as `perl theScript.pl`.
 * If the script is in a different directory from which you are trying to run it, you will need to provide the full path to the script's file, such as `perl /Users/myself/foldername/theScript.pl`.
 * Some scripts may allow you to use options, or require that you provide input files. To learn how to use those scripts, open them in a text editor app (such as *TextEdit* on MacOS or *Notepad* on Windows) and read the documentation in the header of the file.

## Getting Involved

Send suggestions for changes to the Perl Scripts project maintainer, [Dr. Ken Lunde](mailto:lunde@adobe.com?subject=[GitHub]%20Perl%20Scripts), for consideration.
