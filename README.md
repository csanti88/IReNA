
<!-- README.md is generated from README.Rmd. Please edit that file -->

# IReNA

<!-- badges: start -->
<!-- badges: end -->

IReNA (Integrated Regulatory Network Analysis) is to reconstruct
regulatory networks through integrating scRNA-seq and ATAC-seq data.

## Citation

If you use IReNA package, please cite the following Science
paper: <https://science.sciencemag.org/content/370/6519/eabb8598>.

## Workflow

![workflow](workflow.png)

## Installation

First, install Rsamtools and ChIPseeker packages which are needed to run
IReNA.

``` r
install.packages('BiocManager')
BiocManager::install('Rsamtools')
BiocManager::install('ChIPseeker')
```

Second, to install IReNA from GitHub, run:

``` r
install.packages("devtools")
devtools::install_github("jiang-junyao/IReNA")
```

## Example

### Step 1: Run dnase2tf to get footprints.

dnase2tf need input 5 paths as Arguments: (1) datafilepath: the
directory path+ the file name prefix of the DNaseI sequence reads. (2)
hotspotfilename: the file name of the genomic regions of interest in a
BED-like file format. (3) mapfiledir: the mappability file directory of
the reference genome used for alignment. (4) outputfilepath: the
directory path + the file name prefix for the output files. (5)
assemseqdir: the directory path of the assembly sequence files. If you
run dnase2tf in windows system please set the argument ‘numworker’ as 1.
For more details of arguments in dnasetf2, please see:
<https://github.com/jiang-junyao/dnase2tf>

``` r
###install dnase2tf
devtools::install_github('jiang-junyao/dnase2tf')
###Generating hotspotfile
peak_counts_bed<-read.delim("mmATACPhxW_AllPeaks_Counts.txt")
peak_counts_bed<-peak_counts_bed[1:(nrow(peak_counts_bed)-7),1:3]
write.table(peak_counts_bed,'hotspot.bed',row.names=F, col.names=F, sep=' ', quote=F)
###please define datafilepath, hotspotfilename, mapfiledir, outputfilepath, assemseqdir first, and then run the dnase2tf function.
dnase2tf(datafilepath,hotspotfilename, mapfiledir, outputfilepath, assemseqdir, biascorrection='dimer', FDRs = c(0.01, 0.05, 1), numworker=30, paired=T)
```

### Step 2: Select DNA motif of transcription factors from TRANSFAC database

IReNA contains DNA motif datasets for four species (Homo sapiens, Mus
musculus, Zebrafish and Chicken) derived from TRANSFAC 2018 database.
Following codes are used to call the motif dataset from TRANSFAC or
user-defined motif dataset which should have the same format as these
from TRANSFAC database.

``` r
###call Mus musculus motif database
motif1 <- Tranfac201803_Mm_MotifTFsF
###call Homo sapiens motif database
motif1 <- Tranfac201803_Hs_MotifTFsF
###call Zebrafish motif database
motif1 <- Tranfac201803_Zf_MotifTFsF
###call Chicken motif database
motif1 <- Tranfac201803_Ch_MotifTFsF
```

### Step 3: Perform IReNA

First, we merge footprints whose distance is less than 4 and get fasta
from each footprints based on reference genome through function
get\_merged\_fasta(). Reference genome should be fasta/fa format, and
you can download it from
<https://hgdownload.soe.ucsc.edu/downloads.html#alpaca> or other genome
database website.

``` r
library(IReNA)
###merge footprints whose distance is less than 4
footprints <- read.table('mmATACPhxW_CuFiQ10No_sorted_fdr0.050000.bed',,sep='\t',header = T)
fastadir <- 'Genome/GRCm38Chr.fasta' 
merged_fasta <- get_merged_fasta(fdr005,fastadir)
write.table(merged_fasta,'merged_footprints.fasta',row.names=F,quote=F)
```

In this step, because Fimo software only have linux version, and it
takes too long to implement the corresponding function on Windows, we
generate a shell script to run Fimo software in shell. If you are
familiar with linux system and Fimo, you can write your own commands as
you like.

``` r
Dir2 <- 'D:\\GIBH\\IReNA2 R package\\IReNA2\\ATAC\\outputdir'
find_motifs(motif1,step=20,Dir2,'merged_footprints.fasta')
### run the following commands in the shell
mv fimo_all.txt fimo_all.sh
chmod +x fimo_all.sh
sh ./fimo_all.sh
```

After get the result of Fimo, we can use
[winscp](https://winscp.net/eng/download.php) or other related software
to transfer fimo result files from linux to windos(If you use R in
linux, please ignore this part). Then, we combine these Fimo consequence
according to motif and motif Position weight matrix. Next, we load the
peaks file and overlap differential peaks and motif footprints through
overlap\_footprints\_peaks() function

``` r
###Combine all footprints of motifs
combied <- combine_footprints(motif1,Dir2)
peaks <- read.delim('D:\\GIBH\\IReNA2 R package\\IReNA2\\ATAC\\Peaks\\mmATACPhxW_FcLog15Fdr05Diff.txt')
peak_bed <- get_bed(peaks)
overlapped <- overlap_footprints_peaks(combied,peak_bed)
```

However, the running time of overlap\_footprints() is too long, so it’s
highly recommanded to use bedtools to do overlap in linux system:

``` r
write.table(peak_bed,'peaks.bed',col.names=F,row.names=F,quote = F,sep = '\t')
write.table(combied,'combied.txt',quote = F,row.names = F,col.names = F,sep = '\t')
### run the following commands in the shell
bedtools intersect -a combied.txt -b peaks.bed -wa -wb > overlappd.txt
```

Next, we intergrate bioconductor package
[ChIPseeker](https://bioconductor.org/packages/release/bioc/vignettes/ChIPseeker/inst/doc/ChIPseeker.html)
to get footprint-related genes. Before we run get\_related\_genes(), we
need to specify TxDb, which can be download from:
<http://bioconductor.org/packages/release/BiocViews.html#___TxDb>.

``` r
###Merge and extend footprint regions
overlapped <- read.table('overlapped.txt')
###get footprint-related genes
library(TxDb.Mmusculus.UCSC.mm10.knownGene)
txdb <- TxDb.Mmusculus.UCSC.mm10.knownGene
list1 <- get_related_genes(overlapped,txdb = txdb,motif=Tranfac201803_Mm_MotifTFsF,Species = 'Mm')
###Get candidate genes/TFs-related peaks
expression <- read.delim('D:\\GIBH\\IReNA2 R package\\IReNA2\\scRNA\\MmscRNA_PHx_Exp_NewF.txt')
list2 <- get_peaks_genes(list1,expression)
```

In this step, we count the cuts of each position in footrprints by
wig\_track(), and use hese cuts to calculate the FOS of footprints to
identify enriched TFs which determine the regulatory relationship.

``` r
bamfilepath1 <- 'mmATACCtrW00R1_CuFiQ10No_sorted.bam'
bamfilepath2 <- 'mmATACCtrW00R2_CuFiQ10No_sorted.bam'
cuts1 <- wig_track(bamfilepath = bamfilepath1,bedfile = list2[[2]])
cuts2 <- wig_track(bamfilepath = bamfilepath2,bedfile = list2[[2]])
wig_list <- list(cuts1,cuts2)
regulatory_relationships <- Footprints_FOS(wig_list,list2[[1]],MmscRNA_PHx_Exp_NewF)
```

Use functions in GReNA to get regulatory networks for enriched TFs of
each module and intramodular network. For more details of GReNA, please
see <https://github.com/jiang-junyao/GReNA>

``` r
devtools::install_github('jiang-junyao/GReNA')
library(GReNA)
###Perform enrichment analysis of TFs###Get the list of enriched TFs 
TFs_list <- get_regulation_of_TFs_to_modules(TFs_list, Thr=10)
###Get regulatory networks which consist of enriched TFs
tf_network <- get_partial_regulations(TFs_list)
TFs_list <- get_Enriched_TFs(regulatory_relationships, Kmeans_clustering_ENS, TFFdrThr1=2)
###Generate intermodular regulatory networks
intramodular_network <- merge_Module_Regulations(TFs_list, Kmeans_clustering, ModuleThr1=0.05)
```
