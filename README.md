
### About PAVE

PAVE is a transcriptomics-directed pipeline that enables analysis and visualization of differentially expressed genes and pathways.

Created by Margaret Antonio during the Charleston NSF REU for computational genomics.

The PAVE workflow consists of the TUXEDO Suite pipeline followed by custom-made Perl scripts and biological pathway databases, Reactome and Kegg. The goal of PAVE is to take RNA-Seq data and extract biologically relevant results into a simple summary of differentially expressed genes and ranked differentially expressed pathways for the given samples.


### Tuxedo Pipeline Workflow

<img src="https://pavetx.files.wordpress.com/2016/01/tuxedopipeline.jpg?w=1050">


<h2>Versions of Pipeline Tools</h2>

FastQC 0.11.3 <br /> 
Trimmomatic 0.33<br /> 
TopHat 2.0.12<br /> 
Cufflinks: Cuffmerge, Cuffquant, Cuffdiff 2.2.1 <br /> 

##### Trimmomatic: trim adapter sequences from reads
Documentation and command line options on Usadel Lab wesbiste [here](http://www.usadellab.org/cms/?page=trimmomatic)
```bash
#Example of Trimmomatic Command. All others look just like this except with different labels of course
java -jar ../../bin/Trimmomatic-0.33/trimmomatic-0.33.jar PE shFli1_5322_passage_16_R1.fastq.gz shFli1_5322_passage_16_R2.fastq.gz  shFli1_5322_passage_16_R1_trimmo_paired.fq.gz shFli1_5322_passage_16_R1_trimmo_unpaired.fq.gz shFli1_5322_passage_16_R2_trimmo_paired.fq.gz shFli1_5322_passage_16_R2_trimmo_unpaired.fq.gz ILLUMINACLIP:../../TruSeq2Burnett.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:40 >goodles_trimmoLOF53225324.log 
```
##### Tophat: align reads to hg19 genome
Documentation and command line options: see [manual](https://ccb.jhu.edu/software/tophat/manual.shtml)
```bash
tophat2 -p 20 -o tophat_Fli_A ../../../reference_genomes/Homo_sapiens/UCSC/hg19/Sequence/Bowtie2Index/genome GOF/Ad_Fli1_R1_trimmo_paired  GOF/Ad_Fli1_R2_trimmo_paired
```
##### CUFFLINKS
See documentation and command line options on [Cole-Trapnell Lab webiste](http://cole-trapnell-lab.github.io/cufflinks/manual/)
```bash

#Use -g option to give annotated genome (originates from UCSC) genes.gtf

cufflinks -p 10 -o link_Fli_A -g sequence/genes.gtf tophat_Fli_A/accepted_hits.bam
```
##### CUFFMERGE
See documentation and command line options on [Cole-Trapnell Lab webiste](http://cole-trapnell-lab.github.io/cufflinks/manual/)

Make text file transcriptGTFs_A.txt that contains transcripts.gtf files from ALL samples
```bash
cuffmerge -p 20 -o mergeA -g ../../../reference_genomes/Homo_sapiens/UCSC/hg19/Sequence/Bowtie2Index/genome transcriptGTFs_A.txt
```
##### CUFFQUANT: quantify transcripts
```bash
cuffquant -p 10 -o quant_parental_A mergeA/merged.gtf tophat_parental/accepted_hits.bam
```
##### CUFFDIFF: Calculate fold change for differential expression

NOTE: using -p -o -L -b flags Really -b is useless
```bash
cuffdiff -p 20 -o diff_A -L Ad_GFP,Ad_Fli,Ad_PDEF,sh_5322,sh_5324,parental,sh_control -b sequence/genome.fa mergeA/merged.gtf quant_GFP_A/abundances.cxb quant_Fli_A/abundances.cxb quant_PDEF_A/abundances.cxb quant_5322_A/abundances.cxb quant_5324_A/abundances.cxb quant_parental_A/abundances.cxb quant_control_A/abundances.cxb
```


### Analysis Workflow


<img src="https://pavetx.files.wordpress.com/2016/01/pathway_de_gene_analysis.jpg?w=1332">

