import sys
print "This is the name of the script: ", sys.argv[0]
print "Text file of genes which to-keep lines should contain: ", sys.argv[1]
print "INPUT CSV file to search: ",sys.argv[2]
inCSV=sys.argv[2]
root=inCSV.split('.')[-2]
outCSV=root+"_clean.csv"
print "OUTPUT CSV file to write: ",outCSV

TXT_file = sys.argv[1]
CSV_file = sys.argv[2]
OUT_file = outCSV

print "Looking for gene names in second column of ", sys.argv[1],"\n"

## From the TXT, create a list of domains you do not want to include in output
with open(TXT_file, 'r') as txt:
    keep_list = []
    ## for each domain in the TXT
    for line in txt:
        gene=line.split('\n')[0]
        keep_list.append(gene)
with open(OUT_file, 'w') as outfile:
    with open(CSV_file, 'r') as csv:
        ## for each line in csv extract the csv domain
        for line in csv:
            csv_gene = line.split(",")[1]
            if (csv_gene in keep_list):
                outfile.write(line)

# clean_gene=csv_gene.split(". ")[1]
# print clean_gene
# myList=clean_gene,line.split(",")[1]
# print myList
# clean_line=",".join(myList)
# if csv domain is in genes to keep list then write to out file
