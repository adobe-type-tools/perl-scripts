#!/usr/bin/perl

# Written by Dr. Ken Lunde (lunde@adobe.com)
# Senior Computer Scientist 2, Adobe Systems Incorporated
# Version 12/16/2017

# This tool takes an 'sfnt' font collection, such as an OTC (OpenType/
# CFF Collection) or TTC (TrueType Collection), as its only command-
# line argument, then lists the number of fonts (as determined by the
# number of 'name' table instances), a listing of which tables are
# completely unshared, partially shared, and completely shared, along
# with a list of each table and the number of their instances, sorted
# from highest to lowest.
#
# Tool Dependencies: spot (AFDKO)

$unshared = $partially_shared = $shared = "";

$file = $ARGV[0];
open(FILE,"spot -T $file |") or die "Cannot open $file!\n";

while(defined($line = <FILE>)) {
    chomp $line;
    if ($line =~ /\'(....)\'((?:,[0-9a-f]{8}){3})}/) {
        $data->{$1}{$2} = 1;
    }
}

$fonts = scalar keys $data->{name};

foreach $table (sort {$a cmp $b} keys %{ $data }) {
    if (scalar keys %{ $data->{$table} } == 1) {
        if (not $shared) {
            $shared = $table;
        } else {
            $shared .= ", " . $table;
        }
    } elsif (scalar keys %{ $data->{$table} } == $fonts) {
        if (not $unshared) {
            $unshared = $table;
        } else {
            $unshared .= ", " . $table;
        }
    } else {
        if (not $partially_shared) {
            $partially_shared = $table;
        } else {
            $partially_shared .= ", " . $table;
        }
    }
}

print STDOUT "Number of Fonts: $fonts\n";
print STDOUT "Completely Unshared Tables: $unshared\n";
print STDOUT "Partially Shared Tables: $partially_shared\n";
print STDOUT "Completely Shared Tables: $shared\n";

foreach $table (sort { scalar keys $data->{$b} <=> scalar keys $data->{$a} } keys %{ $data }) {
    $count = scalar keys %{ $data->{$table} };
    print STDOUT "$table = $count\n";
}
