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
