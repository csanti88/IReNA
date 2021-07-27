
<!-- README.md is generated from README.Rmd. Please edit that file -->

# IReNA

<!-- badges: start -->
<!-- badges: end -->

IReNA (Integrated Regulatory Network Analysis) is to reconstruct
regulatory networks through integrating scRNA-seq and ATAC-seq data.

## Citation

If you use IReNA package, please cite the following Science
paper: <https://science.sciencemag.org/content/370/6519/eabb8598>.

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

``` r
devtools::install_github('jiang-junyao/dnase2tf')
peak_counts_bed<-read.delim("mmATACPhxW_AllPeaks_Counts.txt")
peak_counts_bed<-peak_counts_bed[1:(nrow(peak_counts_bed)-7),1:3]
write.table(peak_counts_bed,'hotspot.bed',row.names=F, col.names=F, sep=' ', quote=F)
dnase2tf(datafilepath=DNase-seq reads,filename=hotspot.bed, mapfiledir=Mappability, outputfilepath=outputpath, assemseqdir=assemseqdir1, biascorrection='dimer', FDRs = c(0.01, 0.05, 1), numworker=30, paired=T)
```

### Select DNA motif of transcription factors from TRANSFAC database

IReNA contains DNA motif datasets for four species (Homo sapiens, Mus
musculus, Zebrafish and Chicken) derived from TRANSFAC 2018 database.
Following codes are used to call the motif dataset from TRANSFAC or
user-defined motif dataset which should have the same format as these
from TRANSFAC database.

``` r
###call Mus musculus motif database
motif1 = Tranfac201803_Mm_MotifTFsF
###call Homo sapiens motif database
motif1 = Tranfac201803_Hs_MotifTFsF
###call Zebrafish motif database
motif1 = Tranfac201803_Zf_MotifTFsF
###call Chicken motif database
motif1 = Tranfac201803_Ch_MotifTFsF
```

### IReNA pipline

``` r
library(IReNA)
###merge footprints whose distance is less than 4
footprints <- read.table('mmATACPhxW_CuFiQ10No_sorted_fdr0.050000.bed',,sep='\t',header = T)
fastadir='Genome/GRCm38Chr.fasta'
merged_fasta <- get_merged_fasta(fdr005,fastadir)
write.table(merged_fasta,'merged_footprints.fasta',row.names=F,quote=F)
```

In this step, because Fimo software only have linux version, we generate
a shell script to run Fimo software in shell. If you are familiar with
linux system, you can write your own commands as you like.

``` r
Dir2='D:\\GIBH\\IReNA2 R package\\IReNA2\\ATAC\\outputdir'
find_motifs(motif1,step=20,Dir2,'merged_footprints.fasta')
### run the following commands in the shell
mv fimo_all.txt fimo_all.sh
chmod +x fimo_all.sh
sh ./fimo_all.sh
```

After you generated motif files, you can use winscp or other related
software to transfer motif files from linux to windos, and continue the
pipline in R.

``` r
###Combine all footprints of motifs
File1<-read.delim('D:\\GIBH\\IReNA2 R package\\IReNA2\\Public\\Tranfac201803_MotifPWM.txt',header = F)
combied<-combine_footprints(motif1,File1,Dir2)
peaks<-read.delim('D:\\GIBH\\IReNA2 R package\\IReNA2\\ATAC\\Peaks\\mmATACPhxW_FcLog15Fdr05Diff.txt')
peak_bed<-get_bed(peaks)
overlapped<-overlap_footprints_peaks(combied,peak_bed)
```

The running time of overlap\_footprints() is very slow, so it’s highly
recommanded to use bedtools to do overlap in linux system:

``` r
write.table(peak_bed,'peaks.bed',col.names=F,row.names=F,quote = F,sep = '\t')
write.table(combied,'combied.txt',quote = F,row.names = F,col.names = F,sep = '\t')
### run the following commands in the shell
bedtools intersect -a combied.txt -b peaks.bed -wa -wb > overlappd.txt
```

Contiunue the pipline in R

``` r
###Merge and extend footprint regions
overlapped<-read.table('overlapped.txt')
###get footprint-related genes
library(TxDb.Mmusculus.UCSC.mm10.knownGene )
txdb<-TxDb.Mmusculus.UCSC.mm10.knownGene
list1[[1]]<-annotate_genes(overlapped,txdb = txdb,Species = 'Mm')
###Get candidate genes/TFs-related peaks
expression<-read.delim('D:\\GIBH\\IReNA2 R package\\IReNA2\\scRNA\\MmscRNA_PHx_Exp_NewF.txt')
list2<-get_peaks(list1,expression)
```

Calculate the FOS of footprints to determine enriched TFs, and then get
regulatory relationships.

``` r
bamfilepath1<-'mmATACCtrW00R1_CuFiQ10No_sorted.bam'
bamfilepath2<-'mmATACCtrW00R2_CuFiQ10No_sorted.bam'
cuts1<-wig_track(bamfilepath1 = bamfilepath,bedfile = list2[[2]])
cuts2<-wig_track(bamfilepath2 = bamfilepath,bedfile = list2[[2]])
wig_list<-list(cuts1,cuts2)
regulatory_relationships=Footprints_FOS(wig_listlist2[[1]],expression)
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
