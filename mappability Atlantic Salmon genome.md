## This is the documentation of how I created mappability files for the atlantic salmon genome

#### 1. Download chromosome fasta files from [ensembl](https://ftp.ensembl.org/pub/release-108/fasta/salmo_salar/dna/) 
```ruby
for file in {1..29}
do
  echo $file
  wget -c https://ftp.ensembl.org/pub/release-108/fasta/salmo_salar/dna/Salmo_salar.Ssal_v3.1.dna_sm.primary_assembly.$file.fa.gz
done
```
##### 1.1 unzip gz files
```ruby
for file in *fa.gz
do
 echo "now gunzipping $file"
 gunzip $file
done;
```
##### 1.2 Get chromosome sizes and save
```ruby
grep '>' *.fa | awk '/[0-9]{5}/{ print $3 }' | awk -F':' '{print "chr"$3"\t"$5}' > chrsize.tsv

# check the contents of tsv file
cat chrsize.tsv
chr10	125877811
chr11	111868677
chr12	101677876
chr13	114417674
chr14	101980477
chr15	110670232
chr16	96486271
chr17	87489397
chr18	84084598
chr19	88107222
chr1	174498729
chr20	96847506
chr21	59819933
chr22	63823863
chr23	52460201
chr24	49354470
chr25	54385492
chr26	55994222
chr27	45305548
chr28	41468476
chr29	43051128
chr2	95481959
chr3	105780080
chr4	90536438
chr5	92788608
chr6	96060288
chr7	68862998
chr8	28860523
chr9	161282225

# manually edit the first line of each fasta into chr notation
e.g. change fasta header to
>chr1
>chr2

# merge all chr  fasta into one
cat *.fa > genome.fa
```
##########################################
Now run umap
1 Dec 2022

wd: /exports/eddie/scratch/pdewari/umap_salmon/umap/umap

screen -S umap_all

conda activate umap_env
$ python --version
Python 2.7.15
$ bowtie --version
bowtie version 1.1.2

# running via conda env, so no need to declare location of bowtie-build
# if not using conda, just load a bowtie module, find where it is 'which bowtie' and then use that location

# inititate umap to create jobs
python ubismap.py data/genome.fa data/chrsize.tsv data/TestGenomeMappability all.q bowtie-build --kmer 100 150 -write_script test_run.sh

#now run each job inside test_run.sh manually via bash
............................................................................................................................................
#index genome
bowtie-build data/TestGenomeMappability/genome/genome.fa data/TestGenomeMappability/genome/Umap_bowtie.ind

Total time for backward call to driver() for mirror index: 01:14:01
real    151m54.744s
user    143m2.874s
sys     0m19.801s

du -sh data/TestGenomeMappability/genome/*
2.4G	data/TestGenomeMappability/genome/genome.fa
686M	data/TestGenomeMappability/genome/Umap_bowtie.ind.1.ebwt
298M	data/TestGenomeMappability/genome/Umap_bowtie.ind.2.ebwt
128K	data/TestGenomeMappability/genome/Umap_bowtie.ind.3.ebwt
596M	data/TestGenomeMappability/genome/Umap_bowtie.ind.4.ebwt
686M	data/TestGenomeMappability/genome/Umap_bowtie.ind.rev.1.ebwt
298M	data/TestGenomeMappability/genome/Umap_bowtie.ind.rev.2.ebwt

............................................................................................................................................
#get kmers
#first check how many job ids we need..  2512, the file below has header so no. of lines - 1 for header. see below
wc -l data/TestGenomeMappability/chrsize_index.tsv 
2513 data/TestGenomeMappability/chrsize_index.tsv

run via getkmer_bash.sh, below
********************************
for i in {1..2512};
do
    python get_kmers.py data/TestGenomeMappability/chrsize.tsv data/TestGenomeMappability/kmers/k100 data/TestGenomeMappability/chrs data/TestGenomeMappability/chrsize_index.tsv -job_id $i --kmer k100
    echo "done with $i!!"
done
**************************
. getkmer_bash.sh 
Created all sequences for chr10:1-1000000
done with 1!!
