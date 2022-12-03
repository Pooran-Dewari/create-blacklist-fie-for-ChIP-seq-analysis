#! /bin/bash

#$ -V -cwd
#$ -l h_rt=150:00:00
#$ -l h_vmem=15G
#$ -pe sharedmem 1
#$ -P roslin_macqueen_lab
#$ -t 1-29
#$ -tc 10

module load anaconda
source activate umap_env

echo "Task id is $SGE_TASK_ID"

python unify_bowtie.py data/TestGenomeMappability/kmers/k100 data/TestGenomeMappability/chrsize.tsv -var_id SGE_TASK_ID

echo "done with $SGE_TASK_ID!!"
