IReNA: integrated regulatory network analysis of single-cell
transcriptomes
================

-   [IReNA](#irena)
    -   [1.Installation](#1installation)
    -   [2.Test data download](#2test-data-download)
    -   [3.Workflow](#3workflow)
    -   [4.ATAC-seq data preprocessing](#4atac-seq-data-preprocessing)
    -   [5.IReNA Input](#5irena-input)
        -   [(1).Bam file of each sample](#1bam-file-of-each-sample)
        -   [(2).Peak file of all samples](#2peak-file-of-all-samples)
        -   [(3).Raw counts of scRNA-seq data, or Seurat object, or bulk
            RNA-seq expression
            profile.](#3raw-counts-of-scrna-seq-data-or-seurat-object-or-bulk-rna-seq-expression-profile)
        -   [(4).Footprints file](#4footprints-file)
        -   [(5).Reference genome of your
            species](#5reference-genome-of-your-species)
        -   [(6).Motif database](#6motif-database)
    -   [6.Tutorial](#6tutorial)
        -   [Part 1: Analyze scRNA-seq or bulk RNA-seq data to get basic
            regulatory
            relationships](#part-1-analyze-scrna-seq-or-bulk-rna-seq-data-to-get-basic-regulatory-relationships)
        -   [Part 2: Use RcisTarget to refine regulatory relaionships
            (without ATAC-seq
            data)](#part-2-use-rcistarget-to-refine-regulatory-relaionships-without-atac-seq-data)
        -   [Part 3: Analyze ATAC-seq data to refine regulatory
            relationships (have ATAC-seq
            data)](#part-3-analyze-atac-seq-data-to-refine-regulatory-relationships-have-atac-seq-data)
        -   [Part 4: Regulatory network
            analysis](#part-4-regulatory-network-analysis)
    -   [7.How to cite this package](#7how-to-cite-this-package)
    -   [8.Help and Suggestion](#8help-and-suggestion)

<!-- README.md is generated from README.Rmd. Please edit that file -->

# IReNA

IReNA (Integrated Regulatory Network Analysis) is to reconstruct
regulatory networks through integrating scRNA-seq and ATAC-seq data.
Compared with other regulatory network analysis method (SCENIC), IReNA
provides modularized regulatory network analysis to discover the
biological significance of transcription factors and the regulatory role
of each module throughout the process.

IReNA contains four main part to reconstruct regulatory network:

Part 1: Analyze scRNA-seq or bulk RNA-seq data to get basic regulatory
relationships between transcription factors and genes.

Part 2: Use RcisTarget to refine regulatory relaionships

Part 3: Analyze ATAC-seq data to refine regulatory relationships

Part 4: Regultory network analysis.

![workflow](Readme%20figure/Workflow1.png)

If you **have ATAC-seq data**, use **part 3** to refine regulatory
relationships. If you **don’t have ATAC-seq data**, use **part 2** to
refine regulatory relaionships

If you use ATAC-seq to refine regulatory relationships, you also need a
linux system PC or server with the following softwares:
[samtools](http://www.htslib.org/),
[bedtools](https://bedtools.readthedocs.io/en/latest/) and
[fimo](https://meme-suite.org/meme/doc/fimo.html).

## 1.Installation

IReNA needs R version 4.0 or higher,
[Bioconductor](http://bioconductor.org/) version 3.12.

First install Bioconductor, open R and run:

``` r
if (!requireNamespace("BiocManager", quietly = TRUE))
install.packages("BiocManager")
BiocManager::install(version = "3.12")
```

Next, install a few Bioconductor dependencies that aren’t automatically
installed:

``` r
BiocManager::install(c('Rsamtools', 'ChIPseeker', 'monocle',
                       'RcisTarget', 'RCy3', 'clusterProfiler'))
```

Then, install IReNA from GitHub:

``` r
install.packages("devtools")
devtools::install_github("jiang-junyao/IReNA")
```

Finally, check whether IReNA was installed correctly, start a new R
session and run:

``` r
library(IReNA)
```

## 2.Test data download

Test data used below can be download from
<https://github.com/jiang-junyao/IReNA-test-data>. If you want raw data
of ATAC-seq to run [ATAC-seq analysis
pipline](https://github.com/jiang-junyao/ATAC-seq-pipline), you can
download it from
<https://www.ncbi.nlm.nih.gov/biosample?Db=biosample&DbFrom=bioproject&Cmd=Link&LinkName=bioproject_biosample&LinkReadableName=BioSample&ordinalpos=1&IdsFromResult=357084>

## 3.Workflow

![workflow](Readme%20figure/Workflow.png)

## 4.ATAC-seq data preprocessing

If you use ATAC-seq data to refine regulatory relaionships (part3), you
need to preprocess ATAC-seq raw data(fastq) to get bam, peak and
footprints. So we provide [ATAC-seq analysis
pipline](https://github.com/jiang-junyao/ATAC-seq-pipline) for user to
preprocess ATAC-seq data. The object of this pipline is to get bam file
of each sample, peaks file of all samples and footprints of all samples
as IReNA input. If you are familiar with ATAC-seq data analysis, you can
do it as you like.

## 5.IReNA Input

If you **only use scRNA-seq or bulk RNA-seq** data to run IReNA, you
just need to input (3).Raw counts of scRNA-seq data, or Seurat object,
or bulk RNA-seq expression profile and (6).Motif database

If you use **both ATAC-seq data and scRNA-seq or bulk RNA-seq data**,
you need to input all the following files.

### (1).Bam file of each sample

Bam file of each sample can be generated by the step 11 in [ATAC-seq
analysis pipline](https://github.com/jiang-junyao/ATAC-seq-pipline).

### (2).Peak file of all samples

Peaks file of all samples used here can be generated by the step 8 in
[ATAC-seq analysis
pipline](https://github.com/jiang-junyao/ATAC-seq-pipline).

### (3).Raw counts of scRNA-seq data, or Seurat object, or bulk RNA-seq expression profile.

IReNA provides function to load raw counts of scRNA-seq data, and return
seurat object. If your data is [10X
format](https://support.10xgenomics.com/single-cell-gene-expression/software/pipelines/latest/output/matrices),
set parameter datatype = 0. If your data is normal counts format(txt
suffix), set parameter dayatype =1. If you have your own seurat object,
you can skip load\_counts, and use your own seurat object as
‘seurat\_object’.

``` r
### load 10X counts
seurat_object <- load_counts('10X_data/sample1/', datatype = 0)
### load normal counts
seurat_object <- load_counts('test_data.txt',datatype = 1)
### read seurat object
seurat_object <- readRDS('seurat_object.rds')
```

If you use bulk RNA-seq data to get basic regulatory relationships, just
input your bulk RNA-seq expression matrix as ‘expression\_profile’, Use
the same code as the scRNA-seq data to continue the analysis.

### (4).Footprints file

Footprints file can be generated by the step 10 in [ATAC-seq analysis
pipline](https://github.com/jiang-junyao/ATAC-seq-pipline).

### (5).Reference genome of your species

Reference genome needs to be the same as that used for mapping, you can
download it from [UCSC](https://hgdownload.soe.ucsc.edu/downloads.html).

### (6).Motif database

IReNA contains DNA motif datasets for four species (Homo sapiens, Mus
musculus, Zebrafish and Chicken) derived from [TRANSFAC
201803](https://genexplain.com/transfac/). Following codes are used to
call the motif dataset from TRANSFAC or user-defined motif dataset which
should have the same format as these from TRANSFAC database.

``` r
library(IReNA)
###call Mus musculus motif database
motif1 <- Tranfac201803_Mm_MotifTFsF
###call Homo sapiens motif database
motif1 <- Tranfac201803_Hs_MotifTFsF
###call Zebrafish motif database
motif1 <- Tranfac201803_Zf_MotifTFsF
###call Chicken motif database
motif1 <- Tranfac201803_Ch_MotifTFsF
```

## 6.Tutorial

IReNA contains four main part to reconstruct regulatory network:

Part 1: Analyze scRNA-seq or bulk RNA-seq data to get basic regulatory
relationships

Part 2: Use RcisTarget to refine regulatory relaionships

Part 3: Analyze ATAC-seq data to refine regulatory relationships

Part 4: Regultory network analysis.

If you **have ATAC-seq data**, use **part3** to refine regulatory
relationships. If you **don’t have ATAC-seq data**, use **part2** to
refine regulatory relaionships.

### Part 1: Analyze scRNA-seq or bulk RNA-seq data to get basic regulatory relationships

IReNA supports two input format: (i)path of raw counts, you can input
path of raw counts and use function in GReNA to load data and convert it
to Seurat object; (ii)Seurat object. After you upload the data, IReNA
can calculate pseudotime according to R package monocle and add it to
the metadata of Seurat object.

Our test seurat object only contains differentially expressed genes, so
we set the parameter ‘DEG’ in add\_pseudotime\_DEG\_filter() function as
FALSE, if you seurat object contain all genes, please set this parameter
as TRUE. In paraell, our test seurat object have been normalized, so we
set the parameter ‘normlize1’ in add\_pseudotime\_DEG\_filter() function
as FALSE, if your seurat object only contains raw counts, please set
this parameter as TRUE.

``` r
###Read seurat_object
seurat_object <- readRDS('seurat_object.rds')
###calculate the pseudotime and return monocle object
monocle_object <- get_pseudotime(seurat_object)
###Add pseudotime to the Seurat object
seurat_with_time <- add_pseudotime_DEG_filter(seurat_object, monocle_object,DEG = FALSE,normlize1 = FALSE)
```

Then, cells are divided into 50 bins across pseudotime. The bin is
removed if all genes in this bin have no expression. Gene is filtered if
fold change &lt; 0.01 (setting by the parameter FC). Then, genes will be
clustered through K-means algorithm (K is setting by the parameter K1).

    ###Get expression profiles ordered by pseudotime
    expression_profile <- get_SmoothByBin_PseudotimeExp(seurat_with_time, Bin = 50)
    ###Filter noise and logFC in expression profile
    expression_profile_filter <- fileter_expression_profile(expression_profile, FC=0.01)
    ###K-means clustering
    clustering <- clustering_Kmeans(expression_profile_filter, K1=4)

``` r
clustering[1:5,1:5]
#>        KmeansGroup FoldChangeQ95     SmExp1     SmExp2     SmExp3
#> TCEB3            1      2.395806 -0.2424532 -0.8964990 -0.9124960
#> CLK1             1      2.508335 -0.1819044  0.7624798  0.4867972
#> MATR3            1      2.700294 -1.4485729  0.7837425  0.3028892
#> AKAP11           1      2.415084 -0.6120681 -0.3849580  0.3898393
#> HSF2             1      2.528111 -0.8125698 -0.6166004  0.8533309
```

Visualize your clustering result through heatmap

``` r
plot_kmeans_pheatmap(clustering,ModuleColor1 = c('#67C7C1','#67C1E3','#5BA6DA','#EF9951','#FFBF0F','#C067A9'))
```

![Kmeans](Readme%20figure/Kmeans_plot.png)

Adding Ensmble ID of the genes in the first column, then calculate the
correlation of the gene pair and select gene pairs which contain at
least one gene in transcription factors database and have absolute value
of correlation larger than 0.6(setting by the parameter
correlatio\_filter).

``` r
###Add Ensembl ID as the first column of clustering results
Kmeans_clustering_ENS <- add_ENSID(clustering, Spec1='Hs')
Kmeans_clustering_ENS[1:5,1:5]
#>                 Symbol KmeansGroup FoldChangeQ95     SmExp1     SmExp2
#> ENSG00000011007  TCEB3           1      2.395806 -0.2424532 -0.8964990
#> ENSG00000013441   CLK1           1      2.508335 -0.1819044  0.7624798
#> ENSG00000015479  MATR3           1      2.700294 -1.4485729  0.7837425
#> ENSG00000023516 AKAP11           1      2.415084 -0.6120681 -0.3849580
#> ENSG00000025156   HSF2           1      2.528111 -0.8125698 -0.6166004
```

``` r
### Caculate the correlation
motif1 <- Tranfac201803_Hs_MotifTFsF
regulatory_relationships <- get_cor(Kmeans_clustering_ENS, motif = motif1, 0.6, start_column = 4)
```

### Part 2: Use RcisTarget to refine regulatory relaionships (without ATAC-seq data)

For users who do not have ATAC-seq data, IReNA provides
filter\_regulation function (Based on RcisTarget) to refine regulation
relaionships. Due to the limitations of RcisTarget, this function
currently only supports three species (Hs, Mm and Fly). **So if the
species of your data is not included, and you don’t have ATAC-seq data,
you can use unrefined regulatory relaionships to perform part4 analysis
directly.**

Before run this function, you need to download Gene-motif rankings
database from <https://resources.aertslab.org/cistarget/>, and set the
Rankingspath1 as the path of downloaded Gene-motif rankings database. If
you don’t know which database to choose, we suggest that using
‘hg19-500bp-upstream-7species.mc9nr’ for human, using
‘mm9-500bp-upstream-10species.mc9nr’ for mouse, using
‘dm6-5kb-upstream-full-tx-11species.mc8nr’ for Fly. You can download it
manually, or use R code:

``` r
### Download Gene-motif rankings database
featherURL <- "https://resources.aertslab.org/cistarget/databases/homo_sapiens/hg19/refseq_r45/mc9nr/gene_based/hg19-tss-centered-10kb-7species.mc9nr.feather"
download.file(featherURL, destfile=basename(featherURL)) # saved in current dir
### Refine regulatory relaionships
Rankingspath1 <- 'hg19-500bp-upstream-7species.mc9nr1.feather' # download from https://resources.aertslab.org/cistarget/
filtered_regulatory_relationships <- filter_regulation(regulatory_relationships, 'Hs', Rankingspath1)
```

### Part 3: Analyze ATAC-seq data to refine regulatory relationships (have ATAC-seq data)

For users who have ATAC-seq data, IReNA provides several functions to
calculate related transcription factors of footprints with high FOS to
refine regulatory relationships. We merge footprints whose distance is
less than 4 and get sequence from each footprints based on reference
genome through function get\_merged\_fasta(). Reference genome should be
fasta/fa format, and you can download it from
<https://hgdownload.soe.ucsc.edu/downloads.html#alpaca> or other genome
database website.

``` r
###merge footprints whose distance is less than 4
filtered_footprints <- read.table('footprints.bed',sep = '\t')
fastadir <- 'Genome/hg38.fa' 
merged_fasta <- get_merged_fasta(filtered_footprints,fastadir)
write.table(merged_fasta,'merged_footprints.fasta',row.names=F,quote=F,col.names=F)
```

In this step, because [fimo](https://meme-suite.org/meme/doc/fimo.html)
software only have linux version, and it takes too long to implement the
corresponding function on Windows, we generate a shell script to run
Fimo software in shell. If you are familiar with linux system and Fimo,
you can write your own commands as you like.

First, you need to identify differentially expressed genes related
motifs through motif\_select() function, which can help you to reduce
running time of the subsequent analysis process.

Before run find\_motifs() function, you should set the following four
parameters: (1) fimodir: path of fimo software, if you have added fimo
to the environment variable, just set this argument as ‘fimo’. (2)
outputdir1: output path of shell script. (3) outputdir: output path of
fimo result. (4) motifdir: path of motif file, you can download it from
[TRANSFAC201803](https://genexplain.com/transfac/). (5) sequencedir:
path of sequence which generated by get\_merged\_fasta(). Please note
that, at the end of outputdir and sequencedir must contain / symbol.

``` r
### Identify differentially expressed genes related motifs
motif1 <- motifs_select(Tranfac201803_Hs_MotifTFsF, rownames(Kmeans_clustering_ENS)) ###Kmeans_clustering_ENS was obtained in part1
### run find_motifs()
fimodir <- 'fimo'
outputdir1 <- 'D:/GIBH/IReNA2 R package/IReNA2/ATAC/fimo/'
outputdir <- '/public/home/user/fimo/output/'
motifdir <- '/public/home/user/fimo/Mememotif/'
sequencedir <- '/public/home/user/fimo/merged_footprints.fasta'
find_motifs(motif1,step=20,fimodir, outputdir1, outputdir, motifdir, sequencedir)
```

Then you need to use [winscp](https://winscp.net/eng/download.php) or
other related software to transfer script in outputdir1 to
‘/public/home/user/fimo’ directory in Linux system, and run following
commands (If you make analysis in linux system, ignore transfer part).

    ### run the following commands in the shell
    cd /public/home/user/fimo/
    mkdir output
    sh ./fimo_all.sh

After get the result of Fimo, you can use
[winscp](https://winscp.net/eng/download.php) or other related software
to transfer all files in output directory (fimo result files) from linux
to windos(If you use R in linux, please ignore this part). Then, we
combine these Fimo consequence in Dir2. Notably Dir2 folder should only
contain fimo result files. Next, we load the peaks file and overlap
differential peaks and motif footprints through
overlap\_footprints\_peaks() function

``` r
###Combine all footprints of motifs
Dir2 <- 'D:/GIBH/IReNA2 R package/IReNA2/ATAC/fimo/output/'
combined <- combine_footprints(Dir2)
peaks <- read.delim('D:\\IReNA\\ATAC\\Peaks\\differential_peaks.bed')
overlapped <- overlap_footprints_peaks(combined,peaks)
```

However, the running time of overlap\_footprints() is too long, so it’s
highly recommanded to use bedtools to do overlap in linux system. If you
want to use bedtools to do overlap, you need to output
‘combined\_footprints’ dataframe, and transfer it to shell.(If you make
analysis in linux system, ignore transfer part)

``` r
### output combined_footprints
write.table(combined,'combined.txt',quote = F,row.names = F,col.names = F,sep = '\t')
### Transfer combied.txt and differential_peaks.bed to linux system, and then run the following commands in the shell
bedtools intersect -a combined.txt -b differential_peaks.bed -wa -wb > overlappd.txt
```

Next, we intergrate bioconductor package
[ChIPseeker](https://bioconductor.org/packages/release/bioc/vignettes/ChIPseeker/inst/doc/ChIPseeker.html)
to get footprint-related genes. Before we run get\_related\_genes(), we
need to specify TxDb, which can be download from:
[](http://bioconductor.org/packages/release/BiocViews.html#___TxDb).
Kmeans\_clustering\_ENS used here was obtained in part1.

``` r
### If you make overlap by bedtools, read 'overlapped.txt' to R
overlapped <- read.table('overlapped.txt')
###get footprint-related genes
library(TxDb.Hsapiens.UCSC.hg38.knownGene)
txdb <- TxDb.Hsapiens.UCSC.hg38.knownGene
list1 <- get_related_genes(overlapped,txdb = txdb,motif=Tranfac201803_Mm_MotifTFsF,Species = 'Hs')
###Get candidate genes/TFs-related peaks
list2 <- get_related_peaks(list1,Kmeans_clustering_ENS)
### output filtered footprints
write.table(list2[[1]],'filtered_footprints.bed', quote = F, row.names = F, col.names = F, sep = '\t')
```

Then, because of the size of original bam file is too large, so we need
to use samtools to extract footprints realated regions in bam to reduce
running time of function which analyze bam files in IReNA. (If you use
our [test data](https://github.com/jiang-junyao/IReNA-test-data), just
skip this step)

    ### transfer filtered_footprints.bed to linux system and run the following codes
    samtools view -hb -L filtered_footprint.bed SSC_patient1.bam > SSC1_filter.bam
    samtools view -hb -L filtered_footprint.bed SSC_patient2.bam > SSC2_filter.bam
    samtools view -hb -L filtered_footprint.bed esc.bam > esc_filter.bam

In this step, we count the cuts of each position in footrprints by
wig\_track(), and use these cuts to calculate the FOS of footprints to
identify enriched TFs which determine the regulatory relationship.
regulatory\_relationships used here was calculated in part1.

``` r
### calculate cuts of each each position in footprints
bamfilepath1 <- 'SSC1_filter.bam'
bamfilepath2 <- 'SSC2_filter.bam'
bamfilepath3 <- 'esc_filter.bam'
cuts1 <- wig_track(bamfilepath = bamfilepath1,bedfile = list2[[1]])
cuts2 <- wig_track(bamfilepath = bamfilepath2,bedfile = list2[[1]])
cuts3 <- wig_track(bamfilepath = bamfilepath3,bedfile = list2[[1]])
wig_list <- list(cuts1,cuts2,cuts3)
### get related genes of footprints with high FOS
potential_regulation <- Footprints_FOS(wig_list,list2[[2]])
### Use related genes of footprints with high FOS to refine regulatory relationships
filtered_regulatory_relationships <- regulatory_relationships[regulatory_relationships$TF %in% potential_regulation$TF & regulatory_relationships$Target %in% potential_regulation$Target,]
```

### Part 4: Regulatory network analysis

After we get ‘filtered\_regulatory\_relationships’ and
‘Kmeans\_clustering\_ENS’, we can reconstruct regulatory network. Run
network\_analysis() to get regulatory, this step will generate a list
which contain the following 9 dataframes:

(1)Cor\_TFs.txt: list of expressed TFs in the gene networks.

(2)Cor\_EnTFs.txt: list of TFs which significantly regulate gene modules
(or enriched TFs).

(3)FOSF\_RegMTF\_Cor\_EnTFs.txt: regulatory pairs in which the source
gene is enriched TF.

(4)FOSF\_RegMTF\_Cor\_EnTFs.txt: regulatory pairs in which both source
gene and target gene are enriched TFs.

(5)FOSF\_RegMTF\_Cor\_EnTFs.txt: regulatory pairs only including
regulations within each module but not those between modules, in this
step

(6)TF\_list: enriched TFs which significantly regulate gene modules

(7)TF\_module\_regulation: details of enriched TFs which significantly
regulate gene modules

(8)TF\_network: regulatory network for enriched transcription factors of
each module

(9)intramodular\_network: intramodular regulatory network

``` r
TFs_list <- network_analysis(filtered_regulatory_relationships,Kmeans_cluster_Ens,TFFDR1 = 10,TFFDR2 = 50)
```

We can also make enrichment analysis for differentially expressed genes
in each module. Before you run this function, you need to download the
org.db for your species through BiocManager.

``` r
### Download Homo sapiens org.db
#BiocManger::install('org.Hs.eg.db')
library(org.Hs.eg.db)
### Enrichment analysis
enrichment_KEGG <- enrich_module(Kmeans_clustering_ENS, org.Hs.eg.db, 'KEGG')
#enrichment_GO <- enrich_module(Kmeans_cluster_ENS, org.Hs.eg.db, 'GO')
head(enrichment_KEGG)
#>                ID                    Description module -log10(q-value)
#> hsa03010 hsa03010                       Ribosome      1        5.849500
#> hsa05171 hsa05171 Coronavirus disease - COVID-19      1        3.239688
#> hsa03022 hsa03022    Basal transcription factors      1        2.624850
#> hsa05016 hsa05016             Huntington disease      1        2.215513
#> hsa05014 hsa05014  Amyotrophic lateral sclerosis      1        2.040367
#> hsa05165 hsa05165 Human papillomavirus infection      2        4.147775
#>          GeneRatio  BgRatio       pvalue     p.adjust       qvalue
#> hsa03010    15/120 158/8093 9.460965e-09 1.475910e-06 1.414165e-06
#> hsa05171    14/120 232/8093 7.705080e-06 6.009962e-04 5.758533e-04
#> hsa03022     6/120  45/8093 4.761093e-05 2.475768e-03 2.372194e-03
#> hsa05016    14/120 306/8093 1.629229e-04 6.353992e-03 6.088171e-03
#> hsa05014    15/120 365/8093 3.048162e-04 9.510266e-03 9.112401e-03
#> hsa05165    39/403 331/8093 3.714300e-07 1.077147e-04 7.115817e-05
#>                                                                                                                                                                                                          geneID
#> hsa03010                                                                                                                          6122/6143/6206/63931/6194/51187/6135/6161/6167/6159/6166/64979/9045/6136/6191
#> hsa05171                                                                                                                                  6122/6143/6206/6194/51187/6135/6161/6167/103/6159/6166/9045/6136/6191
#> hsa03022                                                                                                                                                                          9519/2962/6877/2071/2957/6879
#> hsa05016                                                                                                                              9519/5978/5688/7019/51164/498/27089/54205/5708/203068/4536/4512/4535/2876
#> hsa05014                                                                                                                       9782/5688/23064/468/51164/203228/498/27089/54205/5708/203068/4536/4512/4535/2876
#> hsa05165 8312/5529/5610/64398/6932/3912/6655/51382/5595/7976/5518/5296/1021/3696/7473/4790/7450/1027/5528/3280/2335/6772/6654/894/5290/23352/3845/23493/3688/528/3716/5584/836/8313/10474/5293/3913/55844/64764
#>          Count
#> hsa03010    15
#> hsa05171    14
#> hsa03022     6
#> hsa05016    14
#> hsa05014    15
#> hsa05165    39
```

You can visualize regulatory network for enriched transcription factors
of each module through plot\_network() function by setting type
parameter as ‘TF’. This plot shows regulatory relationships between
transcription factors in different modules that significantly regulate
other modules. The size of each vertex determine the significance of
this transcription factor. Yellow edges are positive regulation,grey
edges are negative regulation.

    plot_tf_network(TFs_list)

![tf\_network](Readme%20figure/tf_network.png)

You can visualize intramodular network with enriched function through
plot\_intramodular\_network() function. Before run this function, you
can select one enriched function of each module that you want to present
in the plot. If you input all enriched functions, this function will
automatically select the function with the highest -log10(qvalue) in
each module to present in the plot. What’s more transcription factor
with the most edge numbers in each module will be presented in the plot
too.

``` r
### select functions that you want to present in the figure
enrichment_KEGG <- enrichment_KEGG[c(3,8,15,16),]
### plotting
plot_intramodular_network(list1,enrichment_KEGG,layout = 'circle')
```

![intramodular\_network](Readme%20figure/intramodular_network.png)

It is strongly recommended to use
[Cytoscape](https://cytoscape.org/download.html) to display the
regulatory networks. We provide a function that can provide different
Cytoscape styles. You need to intall and open Cytoscape before running
the function.

``` r
###optional: display the network in cytoscape, open cytoscape before running this function
initiate_cy(TFs_list, layout1='degree-circle', type='TF')
initiate_cy(TFs_list, layout1='grid', type='module')
```

These are the picture we processed through cytoscape, which can show the
regulatory relationship of modularized transcription factors.
![Cytoscape\_network](Readme%20figure/Cytoscape_network.png)
![Cytoscape\_intramodular](Readme%20figure/Cytoscape_intramodular.png)

## 7.How to cite this package

If you use IReNA package, please cite the following Science
paper: <https://science.sciencemag.org/content/370/6519/eabb8598>.

## 8.Help and Suggestion

If you have any question, comment or suggestion, please use github issue
tracker to report coding related issues of CellChat or contact
<jiangjunyao789@163.com>. I will answer you timely, and please remind me
again if you have not received response more than three days.
