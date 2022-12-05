### This document describes methodology of blacklist file creation

##### 1. Change chromosome notation from integer to chr 
Input bam alignment files that we have are not in chr notation, so we first need to change them to chr notation.
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
# <path to Blacklist executable> chr1 > chr1_blacklist.txt
# the script below will create a bed file & append all blacklist regions for each chromosome onto it.
qsub blacklist_all_chr.sh
```
Sample of blacklist bed file
```ruby
cat 
```
