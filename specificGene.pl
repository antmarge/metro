#!usr/bin/perl

#Margaret Antonio
#Get specific gene fc info in all comparisons

#.diff file description: 0-test_id 1-gene_id 2-gene 3-locus 4-sample_1 5-sample_2 6-status 7-value_1 8-value_2 9-log2(fold_change) 10-p_value 11_q-value 12-significant


use strict;
use warnings;
use Getopt::Long;
use List::Util qw[min max];

sub print_usage(){
    
    print "\nRequired:\n";
    print "perl specificGene.pl <input_file.diff> --gene <name_of_GOI> --out <output_filename>\n";
}


#Assign inputs to variables

our ($genes, $out);
GetOptions(
'genes:s' => \$genes,
'out:s' => \$out,
);

sub get_time() {
    my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime(time);
    my @months = qw( Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec );
    my @days = qw(Sun Mon Tue Wed Thu Fri Sat Sun);
    return "$days[$wday] $mday $months[$mon] at $hour:$min:$sec \n";
}

print print_usage(),"\n";
print "\n";
if (!$out){$out=$genes."txt"}
if (!$genes){print "Enter gene name (or gene names as a comma separated list) to search for in .diff file!" and die;}

print get_time;
print "\nLooking for $genes in file...\n\n";

#------------------------------------------------------------------------------------------------#

my $file = $ARGV[0] or die "Need to get input file on the command line\n";
my @genes=split(",",$genes);

open OUT, ">$out.csv";
my $fc;

print OUT get_time,"\nXLOC,gene,comparison,test_status,value_1,value_2,log2FC,FC\n";
foreach my $g(@genes){
    print "Looking for $g...\n";
    open(IN, '<', $file) or die "Could not open '$file' $!\n";
    my $first=<IN>;
    print "First line of in file: $first\n";
    while (my $line = <IN>) {               #Open the input file and go through each line
        my @fields = split("\t",$line);
        my $fields=\@fields;
        if ($fields[2] eq "$g"){
            if ($fields[7]!=0 && $fields[8]!=0){
                $fc=max($fields[7]/$fields[8],$fields[8]/$fields[7]);
            }
            else{
                if ($fields[7]==0){
                    $fc=$fields[8];
                }
                else{
                    $fc=$fields[8];
                }
            }
            print OUT $fields[1],",",$fields[2],",",$fields[4]," v ",$fields[5],",",$fields[6],",",$fields[7],",",$fields[8],",",$fields[9],",",$fc,",","\n";
        }
    }   #went through the whole input file looking for specific gene
print OUT "\n";
close IN;
}

close OUT
