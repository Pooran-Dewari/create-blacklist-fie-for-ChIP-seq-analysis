## This is the documentation of how I created mappability files for the atlantic salmon genome

#### 1. Download chromosome fasta files from [ensembl](https://ftp.ensembl.org/pub/release-108/fasta/salmo_salar/dna/) and prepare genome.fa file
```ruby
for file in {1..29}
do
  echo $file
  wget -c https://ftp.ensembl.org/pub/release-108/fasta/salmo_salar/dna/Salmo_salar.Ssal_v3.1.dna_sm.primary_assembly.$file.fa.gz
done
```
##### 1.1 Extract fasta gz files
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
```

##### 1.3 Manually change fasta header in each file into chr notation
e.g. change fasta header for chromosome 1 to `>chr1`

##### 1.4 Merge all chr fasta into one file
`cat *.fa > genome.fa`

---

#### 2. Run umap on University Eddie server

##### 2.1 Generate job schedule

working directory: /exports/eddie/scratch/pdewari/umap_salmon/umap/umap
```ruby
screen -S umap_all
conda activate umap_env
python --version
#Python 2.7.15
bowtie --version
#bowtie version 1.1.2

# Running via conda env, so no need to declare location of bowtie-build
# If not using conda, just load a bowtie module, find where it is 'which bowtie' and then use that location

# Inititate umap to create jobs
python ubismap.py data/genome.fa data/chrsize.tsv data/TestGenomeMappability all.q bowtie-build --kmer 100 150 -write_script test_run.sh

# This creates test_run.sh file with all jobs/tasks in it, these can be submitted to server directly, or
# Can be run one job at a time manually via bash
# For some reasons, when I submit test_run.sh on server, it fails to create kmers, presumably because it force uses python3
# Therefore, I have to submit each job in test_run.sh manually
# Have a good look at the contents of test_run.sh and run jobs manually (we will still use qsub to submit individual jobs)!!
```
##### 2.2 Index genome

```ruby
# Make sure you have bowtie1 available (either via conda envirnoment or by module load)
# We are still inside the screen umap_all and using conda env
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
```
##### 2.3 get kmers by submitting the script below

###### 2.3.1 for --kmer 100


`qsub kmer_100_job.sh`

```ruby
#contents of kmer_100_job.sh

#! /bin/bash

#$ -V -cwd
#$ -l h_rt=150:00:00
#$ -l h_vmem=15G
#$ -pe sharedmem 1
#$ -P roslin_macqueen_lab
#$ -t 1-2513
#$ -tc 10

module load anaconda
source activate umap_env #this is the environment with python2.2.15

echo "Task id is $SGE_TASK_ID"

python get_kmers.py data/TestGenomeMappability/chrsize.tsv data/TestGenomeMappability/kmers/k100 data/TestGenomeMappability/chrs data/TestGenomeMappability/chrsize_index.tsv -job_id $SGE_TASK_ID --kmer k100

echo "done with $SGE_TASK_ID!!"
```

