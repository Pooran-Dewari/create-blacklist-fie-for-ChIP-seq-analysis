### This document describes methodology of blacklist file creation

##### 1. Change chromosome notation for the bam files from integer to chr 
My input bam alignment files are not in chr notation, so we first need to change them to chr notation.
```ruby
# Header of Input bam file is below
samtools view -H AtlanticSalmon_ChIP-Input_Brain_Immature_Female_R1* | head
@HD	VN:1.6	SO:coordinate
@SQ	SN:1	LN:174498729
@SQ	SN:9	LN:161282225
@SQ	SN:10	LN:125877811
@SQ	SN:13	LN:114417674
@SQ	SN:11	LN:111868677
@SQ	SN:15	LN:110670232
@SQ	SN:3	LN:105780080
@SQ	SN:14	LN:101980477
@SQ	SN:12	LN:101677876
```
Run `change_chr_notation.sh` to change chr notation.  

```ruby
# Header of Input bam file after converting to chr notation
samtools view -H bam_chr/AtlanticSalmon_ChIP-Input_Brain_Immature_Female_R1* | head
@HD	VN:1.6	SO:coordinate
@SQ	SN:chr1	LN:174498729
@SQ	SN:chr9	LN:161282225
@SQ	SN:chr10	LN:125877811
@SQ	SN:chr13	LN:114417674
@SQ	SN:chr11	LN:111868677
@SQ	SN:chr15	LN:110670232
@SQ	SN:chr3	LN:105780080
@SQ	SN:chr14	LN:101980477
@SQ	SN:chr12	LN:101677876
```

##### 2. Index bam files 
Input bam needs to be indexed before running Blacklist.
```ruby
module load igmm/apps/samtools/1.6
ls *.bam | xargs -n1 -P20 samtools index # -P20 Run up to 20 processes at a time
```

##### 3. Run Blacklist 
Blacklis requires all indexed bam input files in input/ and unzipped uint8 mappability files in mappability/ directories. A sample tree is shown below.
In theory, you would need couple of hundreds of input files for generation of meaningful blacklist regions. We used 32 inputs for Atlantic salmon blacklist creation and it seems to have worked fine. If you have fewer inputs (I suppose <10), results might not very reliable, and Blacklist might report a big fraction of the geome as being 'blacklisted'! 
\
Directory structure for running Blacklist programme.

```ruby
tree
#directory structure
├── input
│   ├── Ss1_Input_R1_chr.bam
│   ├── Ss1_Input_R1_chr.bam.bai
│   ├── Ss2_Input_R1_chr.bam
│   ├── Ss2_Input_R1_chr.bam.bai
├── mappability
│   ├── chr10.uint8.unique
│   ├── chr11.uint8.unique
│   ├── chr12.uint8.unique
```

```ruby
# Run Blacklist for each chromosome with the following command.
# <path to Blacklist executable> chr1 > chr1_blacklist.txt
#
# Or you could run Blacklist for all chromosomes in one go using a loop, see below.
# the script below will create a bed file 'atlantic_salmon_blacklist_all.bed' & append all blacklist regions for each chromosome onto it.
qsub blacklist_all_chr.sh
```
##### Chill for a few hours!!

![alt-text](https://github.com/Pooran-Dewari/umap-and-blacklist-ChIP-seq/blob/main/Y9q.gif)

Alright, see below sample contents of atlantic_salmon_blacklist_all.bed.
```ruby
cat atlantic_salmon_blacklist_all.bed | head
# output below
chr1	473600	543600	High Signal Region
chr1	821600	919400	High Signal Region
chr1	1277100	1306500	High Signal Region
chr1	1337100	1460500	High Signal Region
chr1	2312500	2346400	High Signal Region
chr1	3703200	3718700	High Signal Region
chr1	4119700	4180300	High Signal Region
chr1	4443600	4532700	High Signal Region
chr1	5028300	5099800	High Signal Region
chr1	5749600	5831500	High Signal Region

```
```ruby
#Check if blacklist completed successfully for all 1-29 chromosomes.
awk '/chr/{print $1}' atlantic_salmon_blacklist_all.bed | uniq
chr1
chr2
chr3
chr4
chr5
chr6
chr7
chr8
chr9
chr10
chr11
chr12
chr13
chr14
chr15
chr16
chr17
chr18
chr19
chr20
chr21
chr22
chr23
chr24
chr25
chr26
chr27
chr28
chr29
```

You can also check what percentage of the genome is in the blacklist region, the more input samples you feed in, the smaller the % gets.
For Atlantic salmon we get approx 7.5%, not too bad with 32 inputs samples considering whole-genome duplication in salmon.
```ruby
bed_file='atlantic_salmon_blacklist_all.bed'
blacklist=$(cat $bed_file | awk -F'\t' 'BEGIN{SUM=0}{ SUM+=$3-$2 }END{print SUM}')
genome_size=2756584103
fraction=$(printf '%.2f\n' $(echo "($blacklist *100 / $genome_size)" | bc -l))
echo "$fraction% of the genome is in blacklist regions!!"
# 7.53% of the genome is in blacklist regions!!
```
Hope this was helpful!

![alt-text](https://github.com/Pooran-Dewari/umap-and-blacklist-ChIP-seq/blob/main/IAj.gif)
