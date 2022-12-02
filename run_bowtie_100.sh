#! /bin/bash



#$ -V -cwd
#$ -l h_rt=150:00:00
#$ -l h_vmem=15G
#$ -pe sharedmem 1
#$ -P roslin_macqueen_lab
#$ -t 1-2513
#$ -tc 10



module load anaconda
source activate umap_env
module load igmm/apps/bowtie/1.1.2  # need to load this module as can't find location of conda bowtie package


echo "Task id is $SGE_TASK_ID"

python run_bowtie.py data/TestGenomeMappability/kmers/k100 /exports/igmm/software/pkg/el7/apps/bowtie/1.1.2  data/TestGenomeMappability/genome Umap_bowtie.ind -var_id SGE_TASK_ID

echo "done with $SGE_TASK_ID!!"
