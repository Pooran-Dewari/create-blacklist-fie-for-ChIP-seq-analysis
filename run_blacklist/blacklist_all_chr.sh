#! /bin/bash

#$ -V -cwd
#$ -l h_rt=150:00:00
#$ -l h_vmem=15G
#$ -pe sharedmem 1
#$ -P roslin_macqueen_lab
#$ -t 1
#$ -tc 10

module load phys/compilers/gcc/9.4.0 # need this module for GLIBCXX

output="atlantic_salmon_blacklist_all.txt"

touch $output

for i in "chr"{1..29}

do
  echo $i
  ./Blacklist/Blacklist $i >> $output
done
