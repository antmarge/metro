TXT_file = 'CS2A3A_MA1A2A_commonNames.txt'
CSV_file = 'MA_1A2A_common_FC.csv'
OUT_file = 'newMA.csv'

## From the TXT, create a list of domains you do not want to include in output
with open(TXT_file, 'r') as txt:
    keep_list = []
    

    ## for each domain in the TXT
    ## remove the return character at the end of line
    ## and add the domain to list domains-to-be-removed list
    for line in txt:
        gene= line.split('\n')[0]
        keep_list.append(gene)

with open(OUT_file, 'w') as outfile:
    with open(CSV_file, 'r') as csv:

        ## for each line in csv
        ## extract the csv domain
        for line in csv:
            csv_gene = line.split(',')[2]
            print csv_gene

            ## if csv domain is in genes to keep list then write to out file
            if (csv_gene in keep_list):
                outfile.write(line)
