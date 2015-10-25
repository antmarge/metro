#!usr/bin/perl

#Margaret Antonio
#Gets genes from pathways


use strict;
use warnings;
use Getopt::Long;

sub print_usage(){
    
    print "\nperl cornrows.pl <options> <inputfile.tsv> --db <database> --out <nameOutFile>";
    
    print "\nRequired:\n";
    print "In the command line (without a flag), input the name of the .diff file to be parsed\n";
    print "--db \t Name of the database origin of the input file. Either reactome or webgestalt";
    
    print "\nOptional:\n";
    print "--out \t Name of output file. Database name and .txt. extensions will be automatically appended. Default: 'out'\n";
}

our ($db,$out);

GetOptions(
'db:s' => \$db,
'out:s' =>\$out,
);

#==========================================================================================


