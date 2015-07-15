#!usr/bin/perl

#Margaret Antonio

#Script to create a .csv file of fold change comparisons that can be inputed into R for rank comparison statistical analysis

#perl prep.pl <genelistFile.txt> <First.csv> <Second.csv>

#list of common genes should include only ones with
#--output-file is the equivalent of -o

use strict;
use warnings;
use Getopt::Long;

our ($one, $list,$two);
GetOptions(
'L1:s' => \$one,
'L2:s' => \$two,
'list=s'=>\$list,
);


my @L1=split(",",$one);
my @L2=split(",",$two);
my $L1=\@L1;
my $L2=\@L2;
#my $list=$ARGV[0]; #input list of genes that two comparisons have in common (can use VennY with gene lists from crewcut.pl (gene_exp.diff)
my $file1=$ARGV[0];

print "These are the files: \n\tGene List File: $list\n\tCuffdiff file:$file1\n";
print "\nFirst comparison labels: @L1\n Second comparison labels: @L2\n";

open FH,'<',$list;

my $string="";

while (<FH>){
    $string.=$_;
}

close FH;
#print $string, "\n"; GOOD
my @common=split("\n",$string);
my $common=\@common;
#print @common;

my @first;
my @second;
my $i=0;
my %firsthash;
my %secondhash;

#now have array of all common genes between two samples to be compared
#GOAL: find these genes in the gene_exp.diff file for the epecified comparisons and make two columns with fold change of each gene (in same order as array)
open LOG,'>', "run.log";

open (FIRST,'<',$file1);
$i=0;
#my %hash;
#keep index of array of common genes
while (my $line = <FIRST>){
    print "Looking for: $common[$i]\n";
    my @fields=split("\t",$line);
    my $fields=\@fields;
    #print LOG "$fields[0]: $fields[4]----$L2[0] and $fields[5]-----$L2[1] and $fields[2] -----$common[$i]\n";
    if ((($fields[4] eq $L1[0]) and ($fields[5] eq $L1[1])){ #and ($fields[2] eq $common[$i])){
        my @vals=split(",",$fields[2]);
        my $vals=\@vals;
        $firsthash{$vals[0]}=$fields[9];
        #$i++;
        #print "index $i \n";
        #next;
    }
}
while (my ($key,$value)=each %firsthash){
    print $key, "\t", $value,"\n";
}
close FIRST;

open (SEC,'<',$file1);
$i=0;

while (my $line=<SEC>){
   my @fields=split ("\t",$line);
   print LOG "$fields[0]: $fields[4]----$L2[0] and $fields[5]-----$L2[1] and $fields[2] -----$common[$i]\n";
   if (($fields[4] eq $L2[0]) and ($fields[5] eq $L2[1]) and ($fields[2] eq $common[$i])){
       push (@second,$fields[9]);
       print "Just pushed!\n";
       $i++;
       next;
   }
}
close SEC;
close LOG;

my $first=\@first;
my $second=\@second;
open (CSV,'>',"combinedFC.csv");
my $num= scalar @common;
print "\nThis is the size of second $num\n";
my $n;
for ($n=0;$n<scalar @first;$n++){
   print CSV $first[$n],",",$second[$n],"\n";
}

close CSV;