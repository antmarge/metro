#!/usr/local/bin/perl
use strict;
use warnings;
use Data::Dumper;
use File::Basename;

my $title="never";
my @table;
my $numFiles=scalar @ARGV;
print "Number of input files: $numFiles\n";
open (OUT,'>test_topPathways.csv');

for (my $i=0; $i < $numFiles; $i++) {
    my $n=0;
    my $file=$ARGV[$i];
    open (FH,'<', $file);
    print "File is: ", "$file\n";
    my @trash= split("/","$file");
    my $trash_size=scalar @trash;
    my $trash=\@trash;
    my $last=$trash[$trash_size-1];   #20Ar.tsv
    print OUT $last,"\n";
    
    #push (@table,$title);
    
    while (my $line=<FH>){
        
        my @fields = split("\t",$line);
        my $fields=\@fields;
        if ($fields[0] ne "KEGG pathway"){
            next;
        }
        else{
            $n++;
            my $name="$n. $fields[1]";
            my $next=<FH>;
            my @path=($name,$next);
            
            push (@table, [@path]);
            #print scalar @path;
        }
        
    } #end while loop
    
    for my $element(@table){
        my @element=@$element;
        print OUT $element[0], ",",$element[1];
    }
    @table=();
    close FH;
} #end for loop

print "Printing to output file...\n";

close OUT;

print "\nDone with it all....\n";