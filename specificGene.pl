#!usr/bin/perl

#Margaret Antonio
#Get specific gene fc info in all comparisons

#.diff file description: 0-test_id 1-gene_id 2-gene 3-locus 4-sample_1 5-sample_2 6-status 7-value_1 8-value_2 9-log2(fold_change) 10-p_value 11_q-value 12-significant


use strict;
use warnings;
use Getopt::Long;
use List::Util qw[min max];
use Data::Dumper qw(Dumper);

sub print_usage(){
    
    print "\nRequired:\n";
    print "perl specificGene.pl <input_file.diff> --gene <name_of_GOI> --out <output_filename>\n";
    print "-h\t prints usage and options\n";
    print "-g\t Enter single gene name, comma-separated gene names, or a line delimited text file)\n";
    print "-id\t Identify gene by id (Default: identifies gene by name)\n";
    
    print "\nNOTES:\n";
    print "Outputs 0 for log2(fc) if test status was not 'OK'\n";
}


#Assign inputs to variables

our ($g, $out, $h,$id,$name);
GetOptions(
'g:s' => \$g,
'out' => \$out,
'h' =>\$h,
'id'=>\$id,
'name'=>\$name,
);
if ($h){
    print print_usage();
}

sub get_time() {
    my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime(time);
    my @months = qw( Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec );
    my @days = qw(Sun Mon Tue Wed Thu Fri Sat Sun);
    return "$days[$wday] $mday $months[$mon] at $hour:$min:$sec \n";
}
my @genes=();
sub readText(){
    my $file=$g;
    my $string="";
    open (FH,'<',$file);
    while(<FH>){
        $string.=$_;
    }
    close FH;
    my @array=("\n",$string);
    s{^\s+|\s+$}{}g foreach @array;  #get rid of any white spaces that might have been accidentally written into the file
    @genes=[@array];
}

print print_usage(),"\n";
print "\n";



#Determine gene input format: either txt file or comma separated (one or several values)

if (!$g){
    print "Enter gene name, gene names as a comma separated list, or a text file) to search for genes!" and die;
}

my @textTest=split(/\./,$g);

if (($textTest[scalar @textTest -1] eq "txt")){
    my $temp=readText();
    @genes=@$temp;
}
else{
    @genes=split(",",$g);
}


#Input gene_exp.diff file
my $file = $ARGV[0] or die "Need to get input file on the command line\n";
my @fileType=split(/\./,"$file");
if ($fileType[scalar @fileType -1] ne "diff"){
    print "Input file is not a .diff file! Look in the cuffdiff output folder for the gene_exp.diff file\n";
    print "Program shutting down....   :(\n";
    die;
}

print get_time;

#------------------------------------------------------------------------------------------------#

#open OUT, ">$out.csv";
my $fc;

#print OUT get_time,"\nXLOC,gene,comparison,test_status,value_1,value_2,log2FC,FC\n";
my %dict;  #keys=comp, values= (fc, identifer)
foreach my $g(@genes){
    print "Looking for $g...\n";
    open(IN, '<', $file) or die "Could not open '$file' $!\n";
    my $first=<IN>;
    
    #MODIFY: read into hash then pull values from hash. Program is tooooooooo slow with CSV file open so long
    
    while (my $line = <IN>) {               #Open the input file and go through each line
        my @fields = split("\t",$line);
        my $fields=\@fields;
        my $id=$fields[1];
        my $name=$fields[2];
        if ($name eq "$g"){
            my $identifier=$name;
            if ($id){
                $identifier=$id;
            }
            my $comp="$fields[4] v $fields[5]";
            my $logfc=$fields[9];
            if ($fields[6] ne "OK"){
                $logfc="n/a";
            }
            my @vals=($logfc,$identifier);

            $dict{$comp}{$name}=$logfc;
                #print OUT $identifier,",",$comp,",",$logfc,"\n";
        }
    }   #finished going through the whole input file looking for specific gene(s)
    
        #print OUT "\n";
close IN;
}
if ($out){
    foreach my $comp (sort keys %dict) {
        open OUT,'>',$comp.".csv";
        foreach my $geneName (keys %{ $dict{$comp} }) {
            print OUT $geneName,",",$dict{$comp}{$geneName},"\n";
        }
        close OUT;
    }
}
else{
    print Dumper \%dict;
    print "------------------------\n";
}
    

