#!usr/bin/perl

#Margaret Antonio
#Gets pathways from .tsv file that WebGestalt ouptus. Can put pathway lists into VennY


use strict;
use warnings;
use Getopt::Long;

sub print_usage(){

    print "\nperl tonsor.pl <options> <inputfile.tsv>";
    
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
print print_usage(),"\n";
print "\n";

if (!$out){
    $out="out";
}
if ($db eq "webgestalt"){

    my @pathways=();
    my @pathway_ids=();
    
    
    my $file = $ARGV[0] or die "Need to get input file on the command line\n";
    open(INPUT, '<', $file) or die "Could not open '$file' $!\n";
    
    while (my $line = <INPUT>) {               #Open the input file and go through each line
        
        my @fields = split("\t",$line);
        my $fields=\@fields;
        if ($fields[0] ne"KEGG pathway"){
            next;
        }
        push (@pathways,$fields[1]);
        push (@pathway_ids,$fields[2]);
        
    }
    
    close INPUT;
    
    print "\nCreating pathway name file\n";
    
    open (FH1,">$out-wb_pathways.txt");
    foreach my $path(@pathways){
        print FH1 $path, "\n";
    }
    close FH1;
    
    print "\nNow creating pathway id file\n";
    
    open (FH2,">$out_wb_pathway_ids.txt");
    foreach my $id(@pathway_ids){
        print FH2 $id, "\n";
    }
    close FH2;
    
    }

elsif ($db eq "reactome"){
    my @pathways;
    
    my $file = $ARGV[0] or die "Need to get input file on the command line\n";
    open(INPUT, '<', $file) or die "Could not open '$file' $!\n";
    
    while (my $line = <INPUT>) {               #Open the input file and go through each line
        
        my @fields = split("\t",$line);
        my $fields=\@fields;
        push (@pathways,$fields[1]);
        
    }
    
    close INPUT;
    
    print "\nCreating pathway name file\n";
    
    open (FH1,">$out-reactome_pathways.txt");
    foreach my $path(@pathways){
        print FH1 $path, "\n";
    }
    close FH1;
    
}


else{
    print "\nThat is not a supported database. Please enter -db reactome or -db webgestalt.\n" and die;
}
