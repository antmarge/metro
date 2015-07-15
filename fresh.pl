#!usr/bin/perl

#Margaret Antonio

#Script to create a .csv file of fold change comparisons that can be inputed into R for rank comparison statistical analysis

#perl prep.pl --list <genelistFile.txt> --L1 first,second --L2 first,second <tracking file>

#perl fresh.pl --L1 21,33 --L2 25,33 -h --list ../../testGetMatrix/9_rankGenes/common_5322-5324.txt ../../testGetMatrix/genes.fpkm_tracking 

#list of common genes should include only ones with
#--output-file is the equivalent of -o

use strict;
use warnings;
use Getopt::Long;
use Tie::IxHash;

our ($one, $list,$two,$h);
GetOptions(
'L1:s' => \$one,
'L2:s' => \$two,
'list=s'=>\$list,
'h'=>\$h,
);


sub printer{
	print "--L1 \t enter entry number for first comparison sample1,sample2\n";
	print "--L2 \t enter entry number for second comparison sample1,sample2\n";
	print "--list \t name of file containing common genes between the two samples\n";
}

sub log2{
    my $n = shift;
    return log($n)/log(2);
}
#fix labels as arrays

my @L1=split(",",$one);  #@L1=(21,33)
my @L2=split(",",$two);  #@L2=(25,33)
my $L1=\@L1;
my $L2=\@L2;

#Read file with common genes into array
open (FH,'<',$list) or print "Cannot open input tracking file" and die;
my $string="";
while (<FH>){
    $string.=$_;
}
close FH;
my @common=split("\n",$string);
my $common=\@common;

#Open tracking file to pull comparisons
# [4]-GeneSymbol
open (TR,'<', $ARGV[0]) or print "Cannot open input tracking file" and die;
if ($h){
	my $line=<TR>;
	my @header=split("\t",$line);
	print "Entry codes for tracking file:\n";
	for (my $i=0;$i<scalar @header;$i++){
		print $i,":\t",$header[$i],"\n";
	}
	printer();
	die;
}

my $index=0;
my %hash;

my @whole; #have to read the whole gene.fpkm_tracking file into an array because need to sort it alphabetically

open OUT,'>',"out.txt";

while (my $line=<TR>){
	#print "Got to while loop";
	my @fields=split("\t",$line);
    my @gene=split(",",$fields[4]);
    my @imp=($fields[0],$fields[9],$fields[13],$fields[17],$fields[21],$fields[25],$fields[29],$fields[33]);
    $hash{$gene[0]}=@imp;
	#print "Looking for: $common[$i]\n";
}

#Sort both lists
my @swhole=sort { $a->[4] cmp $b->[4]} @whole;
my @scommon=sort {$a cmp $b} @common;
my $i=0;
foreach my $t(@swhole){
	my @t=@$t;
	if ($t[4] eq "$common[$i]"){
         print "\nin if loop\n";
	#print "They're equal\n";
        print
        print $t[$L2[0]],"\t",$t[$L2[1]],"\n";
        if ($t[$L1[0]]!=0 and $t[$L1[1]]!=0 and $t[$L1[0]]!=0 and $t[$L1[1]]!=0){
            my $fc1=log2($t[$L1[0]]/$t[$L1[1]]);
            my $fc2=log2($t[$L2[0]]/$t[$L2[1]]);
            my @vals=($fc1,$fc2);
            $hash{$t[4]}=@vals;
            $i++;
            #print "pushed";
}
    }
}
my $b=0;

print "This is the size of the whole array: ",scalar @swhole,"\n";
foreach my $w(@swhole){
    my @w=@$w;
    print OUT $b,": $w[1]\t";
    $b++;
}

close OUT;

open CSV,'>',"out.csv";
for (my($key,$value)=each %hash){
	print CSV $key;
	my @value=@$value;
	foreach my $v(@value){
		print CSV ",",$v;
	}
	print CSV "\n";
}

close CSV;
