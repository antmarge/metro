#!usr/bin/perl

#Margaret Antonio

#Script to create a .csv file of fold change comparisons that can be inputed into R for rank comparison statistical analysis

#perl prep.pl <genelistFile.txt> <First.csv> <Second.csv>

#list of common genes should include only ones with
#--output-file is the equivalent of -o

my $list=$ARGV[0]; #input list of genes that two comparisons have in common (can use VennY with gene lists from crewcut.pl (gene_exp.diff)
my $file1=$ARGV[1];
my $file2=$ARGV[2];

open (MAIN,'<',$list);

my $string;

while (<MAIN>){
    $string.=$_;
}
my @common=split("\n",$string);
my @first;
my @second

#now have array of all common genes between two samples to be compared
#GOAL: find these genes in the gene_exp.diff file for the epecified comparisons and make two columns with fold change of each gene (in same order as array)

open (FIRST,'<',$file1)
my $i=0                   #keep index of array of common genes
while (my $line<FIRST>){
    my @fields=split("\t",$line);
    if ($fields[2]==$common[$i]){
        push (@first,$fields[)
    }
}