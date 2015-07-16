#!usr/bin/perl

#Margaret Antonio
#Parser for .diff files to just get differentially expressed genes with significant fold change

#.diff file description: 0-test_id 1-gene_id 2-gene 3-locus 4-sample_1 5-sample_2 6-status 7-value_1 8-value_2 9-log2(fold_change) 10-p_value 11_q-value 12-significant


use strict;
use warnings;
use Getopt::Long;

sub print_usage(){
    
    print "\nRequired:\n";
    print "In the command line (without a flag), input the name of the .diff file to be parsed\n";
    
    print "\nOptional:\n";
    print "--fc \t Lowest acceptable fold_change value Default: 2\n";
    print "--ext \t specify output gene file extension (txt, sbt, etc). Default ext= txt for file.txt";
}


#Assign inputs to variables

our ($fc, $ext);
GetOptions(
'fc:i' => \$fc,
'ext' => \$ext,
);

sub get_time() {
    my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime(time);
    my @months = qw( Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec );
    my @days = qw(Sun Mon Tue Wed Thu Fri Sat Sun);
    return "$days[$wday] $mday $months[$mon] at $hour:$min:$sec \n";
}

print print_usage(),"\n";
print "\n";


if (!$fc){$fc=2;}
if (!$ext){$ext=".txt";}

print get_time;
print "\nReady to begin parsing file...\n\n";

#==========================================================================================
#my @genes; #array to temporarily hold significant genes from a single comparison until written to txt file
#my @genes_val1; #array like @genes, but for genes that have val1=0 and val2!=0
#my @genes_val2; #array like @genes, but for genes that have val1!=0 and val2=0
my $num=0;

my $fold_change;

sub uniq {		#subroutine to remove gene duplicates in the @genes array
    my %seen;
    grep !$seen{$_}++, @_;
}

my $file = $ARGV[0] or die "Need to get input file on the command line\n";
open(FH, '<', $file) or die "Could not open '$file' $!\n";

my $dummy=<FH>;			#Skips first line in file (header line)
my $sample1="none";
my $sample2="none";
my %gene_ids;
my %gene_ids2;
my %gene_ids3;

my $log="run.log";
open(LOG,'>',$log);
print LOG "Start: ",get_time(),"\n";
print LOG "Gene significance is based on fold change (value2/value1)\n\nGene files within each comparison:\nA: All genes with nonzero values\nB:Genes with value1=0 and value2 != 0\nC:Genes with value1!=0 and value 2=0\n\n";

while (my $line = <FH>) {               #Open the input file and go through each line
    my @fields = split("\t",$line);
    my $fields=\@fields;
    my @values=split(',',$fields[2]);
    my $name=$values[0];
    my $id=$fields[0];
    ###Printing gene lists from single comparisons
    
    if (($sample1 ne "none") && (($fields[4] ne $sample1) or ($fields[5] ne $sample2))){
        $num++;
        print LOG "Comparison $num: $sample1 v $sample2\n";
        #write @temp array to file and start a new data set
        
        #my @sgenes= sort {$a cmp $b}@genes; #alphabetically sort each of the three gene lists
        #my @fgenes=uniq(@sgenes); #filter gene lists to only include each gene once
        my $file1=$num."A".$ext;
        print LOG "\tA:",scalar %gene_ids,"\n";
        open (FH1,'>',$file1);
        foreach (sort keys %gene_ids) {
            print FH1 "$_ \t $gene_ids{$_} \n";
        }
        close FH1;
        
        #my @sgenes_val1= sort { $a cmp $b}@genes_val1;
        #my @fgenes_val1=uniq(@sgenes_val1);
        print LOG "\tB:",scalar keys %gene_ids2,"\n";
        my $file2=$num."B".$ext;
        open (FH2,'>',$file2);
        foreach (sort keys %gene_ids2) {
            print FH2 "$_\t$gene_ids2{$_}\n";
        }
        close FH2;
        
        #my @sgenes_val2= sort {$a cmp $b}@genes_val2;
        #my @fgenes_val2=uniq(@sgenes_val2);
        print LOG "\tC:",scalar keys %gene_ids3,"\n";
        my $file3=$num."C".$ext;
        open (FH3,'>',$file3);
        foreach (sort keys %gene_ids3) {
            print FH3 "$_ \t$gene_ids3{$_}\n";
        }
        close FH3;

        
        #Empty array ,reset sample names, and increment i for new file
        
        %gene_ids=();
        %gene_ids2=();
        %gene_ids3=();

    } #end of printing if loop
    
    if (($fields[6] ne "OK") or ($fields[2] eq "-")) {     #Only want known genes whose status is OK. Remove FAILED and NOTEST
        $sample1=$fields[4];
        $sample2=$fields[5];
        next;
    }
    
    #Work on making an option here to decide if unknown gene loci are included
    #if ($known && $fields[2] eq "-"){     #If user only wants known genes
    #  next;
    # }
    
    #Make option here for choosing to base significance on fold change or p-value; \
    #splice @fields, 10, 4; #If there are no biological replicates, then remove the p-val related fields


    if ($fields[7]==0 or $fields[8]==0){
        if ($fields[7]==0){
            if ($fields[8]>2){
                $gene_ids2{$id}=$name;
            }
            else{
                next;
            }
        }
        else{
            if ($fields[7]>2){
                $gene_ids3{$id}=$name;
            }
            else{
                next;
            }
        }
    }
    else{
        $fold_change=$fields[8]/$fields[7];
        if ($fold_change<$fc){
            next;
        }
        $gene_ids{$id}=$name;
    }
    $sample1=$fields[4];
    $sample2=$fields[5];
    
} #end of while loop going through file

####To do last comparison

    $num++;
    print LOG "Comparison $num: $sample1 v $sample2\n";
    #write @temp array to file and start a new data set
    
    #my @sgenes= sort {$a cmp $b}@genes; #alphabetically sort each of the three gene lists
    #my @fgenes=uniq(@sgenes); #filter gene lists to only include each gene once
    my $file1=$num."A".$ext;
    print LOG "\tA:",scalar %gene_ids,"\n";
    open (FH1,'>',$file1);
    foreach (sort keys %gene_ids) {
        print FH1 "$_ \t ";
        print FH1 $gene_ids{$_},"\n";
    }
    close FH1;

    #my @sgenes_val1= sort { $a cmp $b}@genes_val1;
    #my @fgenes_val1=uniq(@sgenes_val1);
    print LOG "\tB:",scalar keys %gene_ids2,"\n";
    my $file2=$num."B".$ext;
    open (FH2,'>',$file2);
    foreach (sort keys %gene_ids2) {
        print FH2 "$_ \t ";
        print FH2 $gene_ids2{$_},"\n";
    }
    close FH2;
    
    #my @sgenes_val2= sort { $a cmp $b}@genes_val2;
    #my @fgenes_val2=uniq(@sgenes_val2);
    print LOG "\tC:",scalar keys %gene_ids3,"\n";
    my $file3=$num."C".$ext;
    open (FH3,'>',$file3);
    foreach (sort keys %gene_ids3) {
        print FH3 "$_ \t ";
        print FH3 $gene_ids3{$_},"\n";
    }
    close FH3;


print LOG "\nEnd: ",get_time,"\n";

print "Finished \n\n";

