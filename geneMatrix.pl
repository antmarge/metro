#Margaret Antonio
#margaretantonio@gmail.com
#12 April 2016

#Created for RNA-Seq cuffdiff output...analysis of MUSC-Watson Lab data

#GOAL: create gene log2fc matrix for genes of interest (a list)
#INPUT: gene_exp.diff + geneOfInterest.txt
#OUTPUT: geneMatrixGOI.csv


#Perl Modules used in the script
use strict;
use Getopt::Long;
use List::MoreUtils qw(uniq);

#just to print the whole hash for debugging
use Data::Dumper;

#ASSIGN INPUTS TO VARIABLES
our ($diffFile,$goifile,$cutoff,$outfile);
GetOptions(
'd:s' => \$diffFile,
'g:s' => \$goifile,
'c:i' => \$cutoff,
'o:s' => \$outfile,
);

#Set default value(s)
if (!$cutoff){$cutoff=.05;}
if (!$outfile){$outfile="geneMatrix.csv";}


#For reference: indexes for gene_exp.diff file entries
#Sample1=[4], sample2=[5], test=[6], qvalue=[12]-- make default cutoff .05

my @allcomps; #store names of all comparisons here
my %diff;


#STEP 1: READ IN THE DIFF FILE, STORE EVERYTHING IN A HASH

open (DIFF,"<",$diffFile);

while (<DIFF>){
	#Read a single line an store information
	chomp($_);
	my @line=split("\t",$_);
	my $logfc=$line[9];
	my $sample1=$line[4];
	my $sample2=$line[5];
	#some genes have multiple symbols. Just choose first one
	my @genes=split(",",$line[2]);
	my $gene=$genes[0];
	my $xloc=$line[1];
	my $test=$line[6];
	my $qval=$line[12];
	#Don't assess
	if (($test ne "OK") or ($qval > $cutoff)){
		next;
	}
	#set keys for hash
	my $key=$gene;
	if ($gene eq "-"){
		$key=$xloc;
	}
	my $comp=$sample1.$sample2;
	push (@allcomps,$comp);
	$diff{$comp}{$gene}=$logfc;
}

#Get only unique comparison labels
@allcomps=uniq(@allcomps);

close DIFF;
#print join(",",keys %diff); 



#STEP 2: READ IN THE GENE OF INTEREST FILE AND STORE IT INTO A 1D ARRAY

my @allgenes; #array to store all of the genes of interest

open (GOI, "<", $goifile) or "Cannot open gene of interest file" and die;

@allgenes = <GOI>;
process(\@allgenes);
sub process {
    my $allgenes = shift;
    foreach my $gene (@{$allgenes}) {
        chomp $gene;
        #Handle line by line
    }
}


#print "this is the gene file, ", $goifile,"\n";
#while(my $line=<GOI>){
	#each line in the GOI file is a gene
	#print $line;
	#my @lines=split("\n",$line);
	#my $gene=$lines[0];
	#my $gene=$line;
	##print $gene,"\n";
	#push (@allGOIs,$gene);
#	print $gene;
#}
close GOI;

#STEP 3: CREATE MATRIX OF GENES AND THEIR FOLD CHANGES FOR EACH COMPARISON

my %out; #hash to store everything that is going into the output matrix

#header needs a GOIS--compA---compB--etc--compZ
my @header;
push (@header,"genes");
push (@header,@allcomps);

foreach my $gene(@allgenes){
	#got one gene of interest, now get fcs for all comparisons
	my @allfcs;
	foreach my $comp(@allcomps){
		if (defined $diff{$comp}{$gene}){
			push (@allfcs,$diff{$comp}{$gene});
		}
		else{
		#there was no valid fc value for that gene in this specific comparison
			push (@allfcs,"NA");
			
		}
	}
	#store that gene and its fcs in the output hash
	#print $gene,"\t";
	#print join ("\t", @allfcs);
	$out{$gene}=[@allfcs]; #/
	#now loop back and get the next gene of interest
}

#STEP 4: OUTPUT THE FINAL MATRIX

open (OUTFILE,">",$outfile);

#print the header
print OUTFILE join(",",@header),"\n";

#print DUMPER %out;

#print join(",", keys %out);

while( my( $key, $value ) = each %out ){
	my @values=@{$value};
	print OUTFILE $key, ",",join(",",@values),"\n";
	}
	
close OUTFILE;
	


