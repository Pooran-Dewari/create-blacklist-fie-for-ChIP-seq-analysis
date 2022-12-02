## This is the documentation of how I created mappability files for the atlantic salmon genome

#### 1. Download chromosome fasta files from [ensembl](https://ftp.ensembl.org/pub/release-108/fasta/salmo_salar/dna/) and prepare genome.fa file
Download all fasta files from Ensembl by running the get_fasta.sh script
`sh get_fasta.sh`

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

# check the contents of genome/ ; successful indexing should create six ebwt files
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


