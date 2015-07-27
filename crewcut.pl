#!usr/bin/perl

#Margaret Antonio
#Parser for .diff files to just get differentially expressed genes with significant fold change

#.diff file description: 0-test_id 1-gene_id 2-gene 3-locus 4-sample_1 5-sample_2 6-status 7-value_1 8-value_2 9-log2(fold_change) 10-p_value 11_q-value 12-significant

#0-test_id	1-gene_id	2-gene	3-locus	4-sample_1	5-sample_2	status	7-value_1	8-value_2	log2(fold_change)	test_stat	p_value	q_value	significant


use strict;
use warnings;
use Getopt::Long;
use List::Util qw[min max];

sub print_usage(){
    
    print "\nRequired:\n";
    print "In the command line (without a flag), input the name of the .diff file to be parsed\n";
    
    print "\nOptional:\n";
    print "--fc \t Lowest acceptable fold_change value Default: 2\n";
    print "--ext \t specify output gene file extension (txt, sbt, etc). Default ext= txt for file.txt\n";
    print "--name \t flag for outputing only gene name\n";
    print "--id \t flag for outputing only gene id (XLOC)\n";
}

my $countOK=0;

#Assign inputs to variables

our ($fc, $ext,$name,$id);
GetOptions(
'fc:i' => \$fc,
'ext' => \$ext,
'name'=>\$name,
'id'=>\$id,
);

sub get_time() {
    my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime(time);
    my @months = qw( Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec );
    my @days = qw(Sun Mon Tue Wed Thu Fri Sat Sun);
    return "$days[$wday] $mday $months[$mon] at $hour:$min:$sec \n";
}
print print_usage(),"\n";
print "\n";
my @logger;
my $log="run.log";


if (!$fc){$fc=2;}
if (!$ext){$ext=".txt";}

my $start=get_time();
print "Started: $start\n";

#==========================================================================================
my $num=0;
my $fold_change;

my $file = $ARGV[0] or die "Need to get input file on the command line\n";
open(FH, '<', $file) or die "Could not open '$file' $!\n";

my $dummy=<FH>;			#Skips first line in file (header line)
my $sample1="none";
my $sample2="none";
my %gene_ids;
my %gene_ids2;
my %gene_ids3;
my @gene_ids4; #non zero fc---will use for ranking
my $total=0; #number of all genes (annotated and unannotated)
my $totalAn=0; #number of total genes annotated

push (@logger,$start);
my $description="\nGene files within each comparison:\nA: All genes with nonzero values\nB:Genes with value1=0 and value2 != 0\nC:Genes with value1!=0 and value 2=0\nD:Genes that have a non-zero fold change (annotated or not annotated)\n";
my $foldnum="Fold change filter used: max (value2/value1,value1/value2) > $fc\n";
push (@logger,$description,$foldnum);

print "\nParsing the file...\n\n";
while (my $line = <FH>) {               #Open the input file and go through each line
    my @fields = split("\t",$line);
    $total++;

    ###Printing gene lists from single comparisons
    
    if (($sample1 ne "none") && (($fields[4] ne $sample1) or ($fields[5] ne $sample2))){
        $num++;
        
        printer();
    }
    
##################################  Filtering Genes   #####################################
    
    my @values=split(',',$fields[2]);
    my $name=$values[0];
    my $id=$fields[0];
    

    
    #Only want known genes whose status is OK. Remove FAILED and NOTEST
    if ($fields[2] ne "-"){
        $totalAn++;
        if ($fields[7]!=0 and $fields[8]!=0){
            push(@gene_ids4,$id);
        }
    }
    if (($fields[6] eq "OK") and ($fields[2] ne "-")) {
     
        #dealing with zero fpkms---listB, listC, or ignore
        if ($fields[7]==0 or $fields[8]==0){
            if ($fields[7]==0){
                if ($fields[8]>$fc){
                    $gene_ids2{$id}=$name;
                }
            }
            else{
                if ($fields[7]>$fc){
                    $gene_ids3{$id}=$name;
                }
            }
        }
        #dealing with non-zero fpkms in both sides of comparison
        else{
            $fold_change=max($fields[8]/$fields[7],$fields[7]/$fields[8]);
            if ($fold_change>=$fc){
                $gene_ids{$id}=$name;
            }
        }
    }
    $sample1=$fields[4];
    $sample2=$fields[5];
    
} #end of while loop going through file

####To do last comparison
    $num++;


#print the last comparison
printer();

my $end=get_time();
push (@logger,$end);

print "Writing the log file...\n\n";
#Write the log file
open(LOGG,'>',$log);
foreach my $l(@logger){
    print LOGG $l,"\n";
}
close LOGG;

print "Finished ",get_time()," \n\n";

sub printer{
    if ($name){
        printName();
    }
    elsif ($id){
        printID();
    }
    else{
        printAll();
        
    }
}
sub printAll{
    
    my $anum=scalar keys %gene_ids;
    my $bnum=scalar keys %gene_ids2;
    my $cnum=scalar keys %gene_ids3;
    my $stats="Comparison $num: $sample1 v $sample2\n\tA: $anum\n\tB: $bnum\n\tC: $cnum\n";
    my $totals="Total number of annotated genes: $totalAn\nTotal number of genes:$total";
    push (@logger,$stats);
    push (@logger, $totals);
    
    my $file1=$num."A".$ext;
    open (FH1,'>',$file1);
    foreach (sort keys %gene_ids) {
        print FH1 "$_ \t ";
        print FH1 $gene_ids{$_},"\n";
    }
    close FH1;
    
    my $file2=$num."B".$ext;
    open (FH2,'>',$file2);
    foreach (sort keys %gene_ids2) {
        print FH2 "$_ \t ";
        print FH2 $gene_ids2{$_},"\n";
    }
    close FH2;
    
    my $file3=$num."C".$ext;
    open (FH3,'>',$file3);
    foreach (sort keys %gene_ids3) {
        print FH3 "$_ \t ";
        print FH3 $gene_ids3{$_},"\n";
    }
    close FH3;
    
    #clear hashes
    %gene_ids=();
    %gene_ids2=();
    %gene_ids3=();
    $totalAn=0;
    $total=0;
}


sub printID{
    
    my $anum=scalar keys %gene_ids;
    my $bnum=scalar keys %gene_ids2;
    my $cnum=scalar keys %gene_ids3;
    my $dnum=scalar @gene_ids4;
    my $stats="Comparison $num: $sample1 v $sample2\n\tA: $anum\n\tB: $bnum\n\tC: $cnum\n\tD: $dnum\n";
    my $totals="\tTotal number of annotated genes: $totalAn\n\tTotal number of genes:$total\n";
    push (@logger,$stats);
    push (@logger, $totals);
    
    my $file1=$num."A".$ext;
    open (FH1,'>',$file1);
    foreach (sort keys %gene_ids) {
        print FH1 "$_\n";
    }
    close FH1;
    
    my $file2=$num."B".$ext;
    open (FH2,'>',$file2);
    foreach (sort keys %gene_ids2) {
        print FH2 "$_\n";
    }
    close FH2;
    
    my $file3=$num."C".$ext;
    open (FH3,'>',$file3);
    foreach (sort keys %gene_ids3) {
        print FH3 "$_\n";
    }
    close FH3;
    
    my $file4=$num."D".$ext;
    open (FH4,'>',$file4);
    foreach my $e(@gene_ids4) {
        print FH4 "$e\n";
    }
    close FH4;
    
    #clear hashes
    %gene_ids=();
    %gene_ids2=();
    %gene_ids3=();
    $totalAn=0;
    $total=0;
    @gene_ids4=();
}

sub printName{
    
    my $anum=scalar keys %gene_ids;
    my $bnum=scalar keys %gene_ids2;
    my $cnum=scalar keys %gene_ids3;
    my $stats="Comparison $num: $sample1 v $sample2\n\tA: $anum\n\tB: $bnum\n\tC: $cnum\n";
    my $totals="Total number of annotated genes: $totalAn\nTotal number of genes:$total";
    push (@logger,$stats);
    push (@logger, $totals);
    
    my $file1=$num."A".$ext;
    open (FH1,'>',$file1);
    foreach (sort values %gene_ids) {
        print FH1 $_,"\n";
    }
    close FH1;
    
    my $file2=$num."B".$ext;
    open (FH2,'>',$file2);
    foreach (sort values %gene_ids2) {
        print FH2 $_,"\n";
    }
    close FH2;
    
    my $file3=$num."C".$ext;
    open (FH3,'>',$file3);
    foreach (sort values %gene_ids3) {
        print FH3 $_,"\n";
    }
    close FH3;
    
    #clear hashes
    %gene_ids=();
    %gene_ids2=();
    %gene_ids3=();
    $totalAn=0;
    $total=0;
}
