{
 "cells": [
  {
   "cell_type": "markdown",
   "metadata": {
    "collapsed": false
   },
   "source": [
    "<img src=\"https://mlantonio.files.wordpress.com/2015/07/pathway_de_gene_analysis.jpg\">"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {
    "collapsed": true
   },
   "source": [
    "Cheat Sheet Commands\n",
    "```bash\n",
    "sort ../geneLists/geneID/1A.txt ../geneLists/geneID/2A.txt | awk 'dup[$0]++ == 1'>both.txt\n",
    "\n",
    "awk <below command> <fileName> > <outfile>\n",
    "/^ */ right trim spaces\n",
    "/ *$/ left trim spaces\n",
    "/^$/ delete blank lines\n",
    "\n",
    "```"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {
    "collapsed": true
   },
   "source": []
  },
  {
   "cell_type": "markdown",
   "metadata": {
    "collapsed": true
   },
   "source": [
    "\n",
    "| | Connor 2014| MLA 7/2015| Connor 2014 | MLA 7/2015| Connor 2014 | MLA 7/2015 | \n",
    "|------------------------------------------------------------------------------------------|\n",
    "|Pathway|  Ad_FLI v Ad_GFP |  Ad_FLI v Ad_GFP\t|  Ad_PDEF v Ad_GFP\t|   Ad_PDEF v Ad_GFP| Ad_FLI v Ad_PDEF\t| Ad_FLI v Ad_PDEF|\n",
    "|Osteoclast differentiation\t|1|\t1|\t38|\t19|\t-\t|91|\n",
    "|Focal adhesion\t|2\t|5\t|17|\t55|\t20|\t21\n",
    "|Cytokine-cytokine receptor interaction\t|3\t|3\t|10\t|17\t|6\t|8|\n",
    "|Toll-like receptor signaling pathway\t|4\t|6\t|52\t|42\t|15\t|40|\n",
    "|Metabolic pathways\t|5\t|2\t|1\t|1\t|2\t|1|\n",
    "|Endocytosis\t|6\t|13|\t2|\t4|\t17|\t15|\n",
    "|Pathways in cancer\t|7|\t4|\t5\t|3\t|1\t|2|\n",
    "|NOD-like receptor signaling pathway\t|8\t|7\t|66|\t88|\t43|\t76|\n",
    "|Rheumatoid arthritis\t|9\t|8\t|29\t|76|\t50|\t-|\n",
    "|MAPK signaling pathway\t|10\t|\t16\t|\t3\t|\t2\t|\t3\t|\t3\t|\n",
    "|Phagosome\t|\t13\t|\t-\t|\t8\t\t|49\t\t|87\t\t|-\t|\n",
    "|Chagas disease (American trypanosomiasis)\t\t|16\t|\t9\t\t|68\t|\t58\t|\t76\t|\t59\t|\n",
    "|Cell adhesion molecules (CAMs)\t\t|25\t|\t58\t|\t12\t|\t10\t|\t7\t|\t4\t|\n",
    "|Basal cell carcinoma\t\t|27\t|\t18\t\t|32\t\t|15\t|\t4\t\t|11\t|\n",
    "|Natural killer cell mediated cytotoxicity\t\t|39\t\t|29\t|\t9\t|\t11\t\t|23\t\t|14\t|\n",
    "|Prostate cancer\t\t|49\t\t|28\t\t|13\t\t|9\t|\t16\t|\t17\t|\n",
    "|Wnt signaling pathway\t\t|52\t|\t-\t|\t18\t|\t14\t|\t9\t\t|19\t|\n",
    "|Insulin signaling pathway\t\t|63\t|\t-\t\t|7\t|\t6\t|\t22\t\t|9\t|\n",
    "|p53 signaling pathway\t\t|65\t|\t-\t\t|21\t|\t24\t\t|13\t|\t7\t|\n",
    "|Melanogenesis\t\t|74\t\t|-\t\t|22\t|\t7\t|\t5\t|\t5\t|\n",
    "|Peroxisome\t\t|-\t|\t-\t\t|109\t|\t84\t\t|8\t\t|67\t|\n",
    "|Cell cycle\t\t|-\t\t|-\t|\t6\t|\t8\t\t|10\t|\t6\t|\n",
    "|DNA replication\t|\t-\t\t|-\t\t|4\t\t|5\t\t|46\t|\t25\t|"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {
    "collapsed": true
   },
   "source": [
    "Getting CS FC aligned with MA FC for FlivGFP and PDEFvGFP BOTH using crewcut.pl and fresh.pl on original gene_exp.diff file\n",
    "\n",
    "```bash \n",
    "#Between CS's FlivGFP and PDEFvGFP what are the common genes nonzero foldchange with annotated gene name?\n",
    "sort ../../connor/geneLists/geneIDs/2A.txt ../../connor/geneLists/geneIDs/3A.txt | awk 'dup[$0]++ ==1'> CS_2A3ADcommon_ids.txt\n",
    "\n",
    "#Get side by side comparison of log2(fold_change) for each gene in --list of XLOC ids for FlivGFP and PDEFvGFP\n",
    "perl ~/gitREU/fresh.pl --list CS_2A3ADcommon_ids.txt connor_genes.fpkm_tracking --L1 1,3 --L2 2,3\n",
    "\n",
    "#What are the common gene names between the MA gene_exp.diff 1D,2D and CS gene_exp.diff files\n",
    "sort ../../connor/geneLists/geneNames/2A.txt ../../connor/geneLists/geneNames/3A.txt ../../geneLists/geneNames/1A.txt ../../geneLists/geneNames/2A.txt| awk 'dup[$0]++ ==1'> CS2A3A_MA1A2A_commonNames.txt\n",
    "\n",
    "#Edit removeLines.py\n",
    "\n",
    ">TXT_file = 'CS2A3A_MA1A2A_commonNames.txt'\n",
    ">CSV_file = 'CS_2A3A_common_FC.csv'\n",
    ">OUT_file = 'CS_2A3A_common_FC_clean.csv'\n",
    "\n",
    "#Remove lines in CS_2A3A_common_FC.csv so that only ones for genes (by name) also represented in MA1A2A remain\n",
    "python removeLines.py\n",
    "\n",
    "\tPearson's product-moment correlation\n",
    "\n",
    "data:  rank(flicomp[, 1]) and rank(flicomp[, 2])\n",
    "t = 6.8326, df = 736, p-value = 1.749e-11\n",
    "alternative hypothesis: true correlation is not equal to 0\n",
    "95 percent confidence interval:\n",
    " 0.1751454 0.3109157\n",
    "sample estimates:\n",
    "     cor \n",
    "0.244227 \n",
    "\n",
    "> print(pdefstats)\n",
    "\n",
    "\tPearson's product-moment correlation\n",
    "\n",
    "data:  rank(pdefcomp[, 1]) and rank(pdefcomp[, 2])\n",
    "t = 6.7177, df = 736, p-value = 3.697e-11\n",
    "alternative hypothesis: true correlation is not equal to 0\n",
    "95 percent confidence interval:\n",
    " 0.1711574 0.3071971\n",
    "sample estimates:\n",
    "      cor \n",
    "0.2403572 \n",
    "\n",
    "```\n",
    "perl ~/gitREU/fresh.pl --list MA1A2A_Dcommon_ids.txt ../../../inputs/genes.fpkm_tracking --L1 1,2 --L2 1,3"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 1,
   "metadata": {
    "collapsed": false
   },
   "outputs": [
    {
     "data": {
      "application/javascript": [
       "IPython.load_extensions('drag-and-drop');"
      ],
      "text/plain": [
       "<IPython.core.display.Javascript object>"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    }
   ],
   "source": [
    "%%javascript\n",
    "IPython.load_extensions('drag-and-drop');"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {
    "collapsed": true
   },
   "outputs": [],
   "source": []
  }
 ],
 "metadata": {
  "kernelspec": {
   "display_name": "Python 2",
   "language": "python",
   "name": "python2"
  },
  "language_info": {
   "codemirror_mode": {
    "name": "ipython",
    "version": 2
   },
   "file_extension": ".py",
   "mimetype": "text/x-python",
   "name": "python",
   "nbconvert_exporter": "python",
   "pygments_lexer": "ipython2",
   "version": "2.7.10"
  }
 },
 "nbformat": 4,
 "nbformat_minor": 0
}
