#!usr/bin/perl

#Margaret Antonio

#Script to create a .csv file of fold change comparisons that can be inputed into R for rank comparison statistical analysis

#perl prep.pl <genelistFile.txt> <First.csv> <Second.csv>

#list of common genes should include only ones with
#--output-file is the equivalent of -o

use strict;
use warnings;
use Getopt::Long;

our (@L1, @L2);
GetOptions(
'L1=s' => \@L1,
'L2=s' => \@L2,
);



my $list=$ARGV[0]; #input list of genes that two comparisons have in common (can use VennY with gene lists from crewcut.pl (gene_exp.diff)
my $file1=$ARGV[1];

open (MAIN,'<',$list);

my $string;

while (<MAIN>){
    $string.=$_;
}
my @common=split("\n",$string);
foreach my $c(@common){
    print $c,"\t";
}
my @first;
my @second;
my $i=0;

#now have array of all common genes between two samples to be compared
#GOAL: find these genes in the gene_exp.diff file for the epecified comparisons and make two columns with fold change of each gene (in same order as array)

open (FIRST,'<',$file1);

#keep index of array of common genes
while (my $line=<FIRST>){
    my @fields=split("\t",$line);
    if (($fields[4] eq $L1[0] and $fields[5] eq $L1[1])and ($fields[2]==$common[$i])){
        push (@first,$fields[9]);
        my $i++;
    }
}
close FIRST;

open (SEC,'<',$file1);
$i=0;
while (my $line=<SEC>){
    my @fields=split ("\t",$line);
    if (($fields[4] eq $L2[0] and $fields[5] eq $L2[1]) and ($fields[2]==$common[$i])){
        push (@second,$fields[9]);
        my $i++;
    }
}
close SEC;
my $first=\@first;
my $second=\@second;
open (CSV,'>',"combinedFC.csv");

for (my $n=0;$n< scalar @common;$n++){
    print CSV $first[$n],",",$second[$n],"\n";
}

close CSV;