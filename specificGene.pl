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
    print "-o\t Output all data to .csv file with comparison as filename. Default: Standard Output to terminal\n";
    print "-id\t Identify gene by id (Default: identifies gene by name)\n";
    print "-status\t How to treat genes with a non OK test status. Defualt use 0 in place of log2(fc)\n";

}


#Assign inputs to variables

our ($g, $out,$status,$h,$id,$name,$input,$label);
GetOptions(
'g:s' => \$g,
'o:s' => \$out,
'h' =>\$h,
'id'=>\$id,
'i:s'=>\$input,
'name'=>\$name,
'status'=>\$status,
'l:s'=>\$label
);
if ($h){
    print print_usage();
}
if (!$input){
	print "Need input file." and die;
	}

sub get_time() {
    my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime(time);
    my @months = qw( Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec );
    my @days = qw(Sun Mon Tue Wed Thu Fri Sat Sun);
    return "$days[$wday] $mday $months[$mon] at $hour:$min:$sec \n";
}

my @gene_list=();
sub readText(){
	my $type=$_;
	print "reading the text";
    my $string;
    open (LIST,'<',$g) or (print "Cannot open input gene text file" and die);
    while(<LIST>){
    	chomp($_);
    	push @gene_list,$_;
    	}
    
    close LIST;
    #if ($type eq "txt"){
    #	@gene_list=split("\n",$string);
    #	}
    #else{
    #	@gene_list=split(",",$string);
    #	}
    
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
my @fileType=split(/\./,"$input");
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

#Open file and read into hash
open(IN, '<', $input) or die "Could not open '$input' $!\n";
my %inhash;
while (my $line=<IN>){
	chomp($line);
	my @fields = split("\t",$line);
	my $sig=$fields[13];
    my $test=$fields[6];
        #print $test,$sig,"\n";

    my $id=$fields[1];
    my $name=$fields[2]; #this is the gene symbol, which is used
	#if (($test eq "OK") and ($sig eq "yes")){
		$inhash{$name}=\@fields;
    #}
}
close IN;

#foreach (keys %inhash){
	#print $_,"\t", $inhash{$_},"\n";
	#}

foreach my $gen(@gene_list){
    #print "Looking for $gen...\n";
 
    #MODIFY: read into hash then pull values from hash. Program is tooooooooo slow with CSV file open so long
    if (defined $inhash{$gen}){
    	my @info=@{$inhash{$gen}};
    	my $id=$info[1];
    	my $name=$info[2];
    	my $logfc=$info[9];
		my $identifier=$name;
    	if ($id){ #this is an option
            $identifier=$id;
        }
        #This will be the name of the output file
        my $comp=$info[4]."-".$info[5];
		
		#Now store the info for this gene of interest into a hash
		if (!(defined $dict{$comp}{$identifier})){
            $dict{$comp}{$identifier}=$logfc;
        }
        #elsif (($dict{$comp}{$name} eq "nOK") and ($logfc ne "nOK")){
        #    $dict{$comp}{$name}=$logfc;
        #}
        #print $identifier,",",$comp,",",$logfc,"\n";
        }
    }   #finished going through the gene of interest file
        #print OUT "\n";


if ($out){
	open OUT,'>',$out;
    foreach my $outComp (sort keys %dict) {
        #open OUT,'>',$label.$outComp.".csv";
        foreach my $geneName (keys %{ $dict{$outComp} }) {
            print OUT $geneName,",",$dict{$outComp}{$geneName},"\n";
        }
       
    }
   close OUT;  
}
else{
    print Dumper \%dict;
    print "------------------------\n";
}
    

