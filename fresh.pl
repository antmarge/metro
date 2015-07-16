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
my %some;
my %whole;

#my @whole; #have to read the whole gene.fpkm_tracking file into an array because need to sort it alphabetically

open OUT,'>',"out.txt";

while (my $line=<TR>){
	#print "Got to while loop";
    #print $line;
	my @fields=split("\t",$line);
    #print $fields[4],"\n";
    my $name=$fields[0];
    if ($name eq "-"){next;}
    #print "$name\n";
    my @imp=($fields[0],$fields[9],$fields[13],$fields[17],$fields[21],$fields[25],$fields[29],$fields[33]);
    print $name,":\t";
    foreach my $m(@imp){print $m,",";}
    print "\n";
    if ($name ne "gene_short_name"){
    $whole{$name}=[@imp];
    }
	#print "Looking for: $common[$i]\n";
}
close TR;

foreach (sort keys %whole) {
    print "$_ : ";
    my @va=@{$whole{$_}};
    foreach my $a (@va){
        print $a,"\t";
    }
    print "\n";
}

#Sort both lists
#my @swhole=sort { $a->[4] cmp $b->[4]} @whole;
my @scommon=sort {$a cmp $b} @common;
my $i=0;
my $l=0;

print "\n";
print "\nThis is how big the whole array is: ",scalar %whole,"\n";
print OUT "Genes to check (had value of 0 and log2(fc) could not be calculated):\n";
foreach my $g(@common){
    print $g,"\t";
    my $help=$whole{$g};
    if (!$help){next;}
    print $help,"\n";
    my @values=@$help;
    #if ($values[4]==0 or $values[5]==0){
    #    print OUT $g,"\n";
    #    next;
    #}
    my $fc1=log2($values[7]/$values[4]);
    my $fc2=log2($values[7]/$values[5]);
    my @vals=($fc1,$fc2);
    @{$some{$g}}=@vals;
    #print "pushed";
}

my $b=0;

print "This is the size of the whole array: ".keys(%whole)."\n";

close OUT;

open CSV,'>',"out.csv";
print CSV "gene,sh_controlvsh_5322,sh_controlvsh_5324\n";
foreach (sort keys %some) {
    print CSV "$_ , ";
    my @va=@{$some{$_}};
        print CSV $va[0],",",$va[1];
    
    print CSV "\n";
}


close CSV;
