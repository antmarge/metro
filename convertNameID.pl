#!usr/bin/perl

#Margaret Antonio
#INPUT: list of gene names (maybe common ones with a comparison from another .diff file)
#OUPUT: non-duplicate list of gene IDs corresponding to the gene names (some gene_exp.diff runs have duplicate gene names but with unique XLOC ids ---> choose the first

#METHOD: make a hash table where %hash=( gene: XLOC). if

#.diff file description: 0-test_id 1-gene_id 2-gene 3-locus 4-sample_1 5-sample_2 6-status 7-value_1 8-value_2 9-log2(fold_change) 10-p_value 11_q-value 12-significant


use strict;
use warnings;
use Getopt::Long;
use Getopt::Long qw(GetOptionsFromArray);

sub print_usage(){
    print "perl convertNameID.pl <input-geneNameList.txt> <diff file>";
}
our ($h);
GetOptions(
'h' => \$h,
);


if ($h){
    print_usage();
}

sub get_time() {
    my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime(time);
    my @months = qw( Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec );
    my @days = qw(Sun Mon Tue Wed Thu Fri Sat Sun);
    return "$days[$wday] $mday $months[$mon] at $hour:$min:$sec \n";
}

my $list=$ARGV[0];
my $diff=$ARGV[1];
my %dict;

#Check that inputs are in the correct format

my @alist=split(".",$list);
#my $outName=$alist[0]."_XLOC.txt";

#Open gene_exp.diff file and make hash table of unique genes and their corresponding ids
open (DIFF,'<',$diff);
#or (print "No gene_exp.diff file found!" and die);
my $header=<DIFF>;
while (my $line=<DIFF>){
    my @fields=split("\t",$line);
    my @many=split(",",$fields[2]);
    my $name=$many[0];
    my $id=$fields[1];
    $dict{$name}=$id if (!($dict{$name}))
}
close DIFF;

#Read line delimited text file of gene names into array
open (LIST,'<',$list) or print "Cannot open input gene name list" and die;
my $string="";
while (<LIST>){
    $string.=$_;
}
close LIST;
my @inputNames=split("\n",$string);

#Search for corresponding gene ids to inputted gene names

my @outputIDS;
foreach my $gene(@inputNames){
    push (@outputIDS,$dict{$gene}) if exists $dict{$gene};
}
open (OUT,'>',"out.txt");
foreach my $on(@outputIDS){
    print OUT $on, "\n";
    
}
close OUT;
    
