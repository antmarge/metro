#!usr/bin/perl

#Margaret Antonio
#Gets ranked pathways from files of comparisons and merges them into a single hash table that prints out to a csv file, opens in excel.


use strict;
use warnings;
use Getopt::Long;
use List::Util qw(first);
use Tie::IxHash;

sub print_usage(){
    
    print "\nperl rankPaths.pl --paths <allPathsFile.txt> <input files separated by a space>";
    
    print "\nRequired:\n";
    print "In the command line (without a flag), input the names of the files containing the top pathways for each comparison (line delimited)\n";
    print "--paths \t Name of text file (line delimited) containing all unique pathways found in the input files\n";
    print "--top  \t Integer number for highest acceptable rank for pathway to be included in table\n";
}
our ($paths,$top);

GetOptions(
'paths=s' =>\$paths,
'top:i' =>\$top,
    #Should add label option
);

my @filenames;
if (!$top){$top=10;}


#Get the names of the files comparisons into an array called @filenames

my $numFiles=scalar @ARGV;
print "Number of files: $numFiles\n";


tie my %inputs, "Tie::IxHash";
for (my $i=0; $i < $numFiles; $i++) {
    my $n=0;
    my $file=$ARGV[$i];

    open (FH,'<',$file);
    my $stringInput;
    while (<FH>){
        $stringInput .= $_;
    }
    close FH;
    my @topPaths=split("\n",$stringInput);

    #Get the names of the comparison file associated with the opened file $file ($ARGV[1])
    
    my @trash= split("/","$file");
    my $trash_size=scalar @trash;
    my $last=$trash[$trash_size-1];
    my @sec=split("_","$last");
    my $comp=$sec[0];
    push(@filenames,$comp);
    my $topPaths=\@topPaths;
    $inputs{$comp}=$topPaths;
    
    print "\nThese are the top pathways in $comp\n";
    foreach my $r(@topPaths){
        print $r,"\n";
    }
   
}
#Check hash
print "\n\n";
while (my ($key,$values)=each %inputs){
    print "$key\n";
    foreach my $y(@$values){
        print "\t$y\n";
    }
    print "\n";
}

#Check input files

print "\nInput files:\n";
foreach my $f(@filenames){
    print $f,"\n";
}

#Make the unique pathways list ($paths) into an array that will serve as the keys for the hash
my $pathFile="$paths";
open (PATH,'<',$pathFile);
my $stringPath;
while (<PATH>){
    $stringPath .= $_;
}
my @pathways=split("\n",$stringPath);
close PATH;
foreach my $g(@pathways){
    print $g,"\n";
}

#Building ranking hash with pathways as names (KEYS) and ranks as VALUES
tie my %rank_of, "Tie::IxHash";
foreach my $p(@pathways){
    my @ranks=();
    my $lowest=20;
    print "\n\nLooking for: $p\n";
    while( my ($key,$value)=each %inputs){
        my @value=@$value;
        #print "\n\n";
        my $search_for = $p;
        my $index="-";
        my $check= grep { $value[$_] eq $search_for } 0..$#value;
        if ($check==1){
            $index = first { $value[$_] eq $search_for } 0 .. $#value;
            $index=$index+1;
            if ($index<$lowest){
                $lowest=$index;
            }
        }
        push (@ranks,$index);
        print " $index";
    }
    if ($lowest<$top){
        $rank_of{$p}=[@ranks];
    }
}

my @keys = keys %inputs;

open RANKS,'>',"pathwayRanks.csv";
print RANKS "Pathway";
for (my $l=0;$l<scalar @keys;$l++){
    print RANKS ",",$keys[$l];
}
print RANKS "\n";
while ( my ($key,$value)=each %rank_of){
    print RANKS $key;
    foreach my $r(@$value){
       print RANKS ",",$r;
    }
    print RANKS "\n";
}

