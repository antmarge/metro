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
    
    print "\nRetrieves log2(fc) values for specific genes in all comparisons in a gene_exp.diff file. Can be used for quick retrieval of single gene information or to set up for a heatmap for expression of multiple genes (belonging to a group or pathway, for example) across comparisons\n\n";
    
    print "\nRequired:\n";
    print "perl specificGene.pl [options] <input_file.diff> --genes <name(s)_of_GOI or csv/txt file> \n";
    print "-h\t prints usage and options\n";
    print "-g\t Enter single gene name, comma-separated gene names, or comma separated csv or text file)\n";
    print "-out\t Output all data to .csv file with comparison as filename. Default: Standard Output to terminal\n";
    print "-id\t Identify gene by id (Default: identifies gene by name)\n";
    print "-status\t How to treat genes with a non OK test status. Defualt use 0 in place of log2(fc)\n";

}


#Assign inputs to variables

our ($g, $out,$status,$h,$id,$name);
GetOptions(
'g:s' => \$g,
'out' => \$out,
'h' =>\$h,
'id'=>\$id,
'name'=>\$name,
'status'=>\$status,
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

my @gene_list=();
sub readText(){
    my $string="";
    open (LIST,'<',$g) or (print "Cannot open input gene text file" and die);
    $string=<LIST>;
    close LIST;
    @gene_list=split(",",$string);
    s{^\s+|\s+$}{}g foreach @gene_list;  #get rid of any white spaces that might have been accidentally written into the file
}

print print_usage(),"\n";
print "\n";



#Determine gene input format: either txt file or comma separated (one or several values)

if (!$g){
    print "Enter gene name, gene names as a comma separated list, or a text file) to search for genes!" and die;
}
if (!$status){
    $status=0;
}

my @textTest=split(/\./,$g);
my $ext=$textTest[scalar @textTest -1];
if (( $ext eq "txt") or ( $ext eq "csv")  ){
    readText();
    print "This is the gene list: \n";
}
else{
    @gene_list=split(",",$g);
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
foreach my $gen(@gene_list){
    print "Looking for $gen...\n";
    open(IN, '<', $file) or die "Could not open '$file' $!\n";
    my $first=<IN>;
    
    #MODIFY: read into hash then pull values from hash. Program is tooooooooo slow with CSV file open so long
    
    while (my $line = <IN>) {               #Open the input file and go through each line
        my @fields = split("\t",$line);
        my $fields=\@fields;
        my $id=$fields[1];
        my $name=$fields[2];
        if ($name eq "$gen"){
            my $identifier=$name;
            if ($id){
                $identifier=$id;
            }
            my $comp="$fields[4] v $fields[5]";
            my $logfc=$fields[9];
            if ($fields[6] ne "OK"){
                $logfc=$status;
            }
            my @vals=($logfc,$identifier);

            if (!(defined $dict{$comp}{$name})){
                $dict{$comp}{$name}=$logfc;
            }
            elsif (($dict{$comp}{$name} eq "nOK") and ($logfc ne "nOK")){
                $dict{$comp}{$name}=$logfc;
            }
                #print OUT $identifier,",",$comp,",",$logfc,"\n";
        }
    }   #finished going through the whole input file looking for specific gene(s)
    
        #print OUT "\n";
close IN;
}
if ($out){
    foreach my $outComp (sort keys %dict) {
        open OUT,'>',$outComp.".csv";
        foreach my $geneName (keys %{ $dict{$outComp} }) {
            print OUT $geneName,",",$dict{$outComp}{$geneName},"\n";
        }
        close OUT;
    }
    
}
else{
    print Dumper \%dict;
    print "------------------------\n";
}
    

