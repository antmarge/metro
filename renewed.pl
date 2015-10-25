#!usr/bin/perl

#Margaret Antonio

#Script to create a .csv file of fold change comparisons that can be inputed into R for rank correlation tests



#perl fresh.pl --L1 21,33 --L2 25,33 -h --list ../../testGetMatrix/9_rankGenes/common_5322-5324.txt ../../testGetMatrix/genes.fpkm_tracking 

#

#list of common genes should include only ones with
#--output-file is the equivalent of -o]'


#Add Entrez ID option so ENTREZ ID is outputted

use strict;
use warnings;
use Getopt::Long;

our ($one,$two,$h,$entrez,$color,$filter);
GetOptions(
'L1:s' => \$one,
'L2:s' => \$two,
'h'=>\$h,
'entrez:s'=>\$entrez,
'color'=>\$color,
'f'=>\$filter,
);

sub printer{
    print "\n=======================================================================";
    print "\nRequired:\n";
    print "Without a flag, enter the genes.fpkm_tracking file from cuffdiff output\n";
	print "--L1 \t enter entry codes for first comparison sample1,sample2\n";
	print "--L2 \t OPTIONAL enter entry codes for second comparison sample1,sample2\n";
    print "--entrez \t enter file name of entrez conversion gene name to ids";
    print "--color\t Instead of returning log2(fc)s, give color red for - values and green for + values\n";
    print "--f\t Filter out genes that don't have opposite log2(fc) signs (+ -) and rank those that do\n";
    print "=========================================================================\n";
}

sub log2{
    my $n = shift;
    return (log($n)/log(2));
}
my $list=$ARGV[0];
my $tracker=$ARGV[1];

#Read file with common genes into array
#print "This is the titlename:",$list;

my @title=split(/\./,$list);
my $t=$title[0];

open (FH,'<',$list) or print "Cannot open input tracking file" and die;
my $string="";
while (<FH>){
    $string.=$_;
}
close FH;

my @common=split("\n",$string);
s{^\s+|\s+$}{}g foreach @common;

#Open tracking file to pull comparisons
# [4]-GeneSymbol
open (TR,'<', $tracker) or print "Cannot open input tracking file" and die;
print "This is the tracking file: $ARGV[1]";
print "This is the gene id list: $ARGV[0]";
my $line=<TR>;
my @header=split("\t",$line);

if ($h){
    print "\nEntry codes for tracking file:\n";
    my @codes;
    for (my $i=9;$i<scalar @header;$i+=4){
        push (@codes,$header[$i]);
    }
    my $n=1;
    foreach my $c(@codes){
        print $n,": ",$c,"\n";
        $n++;
    }
    printer();
    die;
}

my $index=0;
my %some;
my %whole;

#my @whole; #have to read the whole gene.fpkm_tracking file into an array because need to sort it alphabetically

my $dummy=<TR>;
while (my $line=<TR>){
    my @fields=split("\t",$line);
    my $id=$fields[0];
    my @names=split(",",$fields[4]);
    my $gene_name=$names[0];
    my @imp=($gene_name);
    for(my $i=9;$i<scalar @header;$i+=4){
        push (@imp,$fields[$i]);
    }
    
    $whole{$id}=[@imp];
    
	#print "Looking for: $common[$i]\n";
}

close TR;


print "\nThis is how big the whole array is: ",scalar %whole,"\n";


#Sort both lists
#my @swhole=sort { $a->[4] cmp $b->[4]} @whole;
my @scommon=sort {$a cmp $b} @common;
my $i=0;
my $l=0;
my @zero=();
print "\n";

#If entrez id option was flagged then open file of gene names and corresponding entrez ids and write into a hash dictionary for conversion from geneName to entrez id
    my %dict;
if ($entrez){
    open ENT,'<',$entrez;
    my $head=<ENT>; #store header
    while (my $line=<ENT>){
        my @entry=split(",",$line);
        #assign geneName---entrezID as hash entry
        my $entrezID=$entry[1];
        chomp $entrezID;
        $dict{$entry[0]}=$entrezID;
    }
    #foreach (sort keys %dict){
        #print $_,": ",$dict{$_},"\n";
    #}
    close ENT;
}

print "\nPulling out genes XLOC ids and calculating fold change\n";
foreach my $g(@scommon){
    my $help=$whole{$g};
    if (!$help) {next;}
    my @values=@$help;
    my @core;

    #The control and test values are only the fpkms for that test condition
    
	my @L1=split(",",$one);
    my $control1=$values[$L1[0]];
    my $test1=$values[$L1[1]];
    
    my @L2=split(",",$two); 
    my $control2=$values[$L2[0]];
    my $test2=$values[$L2[1]];
    
    my $fc1;
    my $fc2;
    
	
	#Calculate log2(fc) for first comparison indicated in L1
	if ($control1==0 and $test1==0){
		$fc1=0;
	}
	else{
		if ($control1==0 and $test1>0){
			$control1=.0001;
		}
		elsif ($control1>0 and $test1==0){
			$test1=.0001;
		}
        $fc1=log2($test1/$control1);
    }
    

	#Calculate log2(fc) for second comparison indicated in L1
	if ($control2==0 and $test2==0){
		$fc2=0;
	}
	else{
		if ($control2==0 and $test2!=0){
			$control2=.0001;
		}
		elsif ($control2!=0 and $test2==0){
			$test2=.0001;
		}
        $fc2=log2($test2/$control2);
    }
    
    # Now decide whether or not to include
	if ($filter){
		if (($fc1>=0 and $fc2<=.0001) or ($fc2>=0 and $fc1<=.0001)){ #log2(fc)s are in different directions
			push (@core,$values[0]);
			push (@core,$fc1);
			push (@core,$fc2);
		}
		else {next;}
	}

	else{

		push (@core,$values[0]);
		push (@core,$fc1);
		push (@core,$fc2);
	}
	
	@{$some{$g}}=@core;
    
    #if (scalar @core !=0){}

}
my $b=0;

print "This is the size of the whole array: ".keys(%whole)."\n";

#Only make the zerofc out text file if there are zero fc genes (if doing all DE genes as oppose to common DE genes)
if (scalar @zero !=0){
    open (OUT,'>',"zerofc.txt") or die;
    print OUT "Genes to check (had value of 0 and log2(fc) could not be calculated):\n";
    foreach my $z(@zero){
        print OUT $z,"\n";
    }
    close OUT;
}

print "\n Writing to the output file\n";

my $outfile="outfile.tsv";
open (CSV,'>',$outfile) or (print "Cannot write to $outfile. Check that directory exists.\n" and die);
open (OUT,'>',"noEntrezGenes.txt");
#print CSV "comp1,comp2,gene_name,gene_id\n";
print "This is the size of the selected array: ".keys(%some)."\n";

if ($color and $entrez){
    open COLOR,'>',"color.tsv";
    foreach (sort keys %some) {
        my @va=@{$some{$_}};
        my $entr=$va[1];
        my $log2fc=$va[0];
        if ((defined $dict{$va[1]}) and ($dict{$va[1]} ne "")){
            $entr=$dict{$va[1]};
            if ($log2fc>=1){
                if ($log2fc>=4){
                    print COLOR "$entr\tblue\n";
                }
                else{
                    print COLOR"$entr\tgreen\n";
                }
            }
            elsif($log2fc<=-1){
                if ($log2fc<=-4){
                     print COLOR "$entr\tred\n";
                }
                else{
                    print COLOR "$entr\tyellow\n";
                }
            }
            
            }
        else{
            print OUT "$entr\t$va[0]\n";
        }
    }
    close COLOR;
    close OUT;  
        
}
   
elsif ($entrez){
    foreach (sort keys %some) {
        my @va=@{$some{$_}};
        my $entr=$va[1];
        if ((defined $dict{$va[1]}) and ($dict{$va[1]} ne "")){
            $entr=$dict{$va[1]};
            print CSV "$entr\t$va[0]\n";
        }
        else{
            print OUT "$entr\t$va[0]\n";
        }

    }
}
else{
    foreach (sort keys %some) {
        my @va=@{$some{$_}};
        print CSV "$va[0]\t$va[1]\t$va[2]\n";
    }
}


close CSV;
