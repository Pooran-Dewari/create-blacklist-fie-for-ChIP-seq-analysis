# Bismap/Umap job submission commands follow.

JOBID=$(qsub -q all.q -terse -N Index-Bowtie -o data/TestGenomeMappability/genome/index_genome.LOG -e data/TestGenomeMappability/genome/index_genome.ERR -cwd -b y bowtie-build data/TestGenomeMappability/genome/genome.fa data/TestGenomeMappability/genome/Umap_bowtie.ind)
IDPARTS=($(echo $JOBID | tr "." "\n"))
WAITID=${IDPARTS[0]}
echo "Submitted JOB ID $WAITID"

JOBID=$(qsub -q all.q -t 1-2513 -N Bismap.UniqueKmers -terse -tc 120 -hold_jid 1 -cwd -b y -o data/TestGenomeMappability/kmers/Bismap.UniqueKmers.LOG -e data/TestGenomeMappability/kmers/Bismap.UniqueKmers.ERR python get_kmers.py data/TestGenomeMappability/chrsize.tsv data/TestGenomeMappability/kmers/k100 data/TestGenomeMappability/chrs data/TestGenomeMappability/chrsize_index.tsv --var_id SGE_TASK_ID --kmer k100)
IDPARTS=($(echo $JOBID | tr "." "\n"))
WAITID=${IDPARTS[0]}
echo "Submitted JOB ID $WAITID"

JOBID=$(qsub -q all.q -t 1-2513 -N Bismap.RunBowtie -terse -tc 120 -hold_jid $WAITID,$WAITID -cwd -b y -o data/TestGenomeMappability/kmers/Bismap.RunBowtie.LOG -e data/TestGenomeMappability/kmers/Bismap.RunBowtie.ERR python run_bowtie.py data/TestGenomeMappability/kmers/k100  data/TestGenomeMappability/genome Umap_bowtie.ind -var_id SGE_TASK_ID)
IDPARTS=($(echo $JOBID | tr "." "\n"))
WAITID=${IDPARTS[0]}
echo "Submitted JOB ID $WAITID"

JOBID=$(qsub -q all.q -t 1-29:1 -N Bismap.UnifyBowtie -terse -tc 120 -hold_jid $WAITID -cwd -b y -o data/TestGenomeMappability/kmers/Bismap.UnifyBowtie.LOG -e data/TestGenomeMappability/kmers/Bismap.UnifyBowtie.ERR python unify_bowtie.py data/TestGenomeMappability/kmers/k100 data/TestGenomeMappability/chrsize.tsv -var_id SGE_TASK_ID)
IDPARTS=($(echo $JOBID | tr "." "\n"))
WAITID=${IDPARTS[0]}
echo "Submitted JOB ID $WAITID"

JOBID=$(qsub -q all.q -N Moving.Intermediary.Files -hold_jid $WAITID -terse -cwd -b y -o Bismap.FileMov.LOG -e Bismap.FileMov.ERR mv data/TestGenomeMappability/kmers/k100/*kmer* data/TestGenomeMappability/kmers/k100/TEMPs)
IDPARTS=($(echo $JOBID | tr "." "\n"))
WAITID=${IDPARTS[0]}
echo "Submitted JOB ID $WAITID"

JOBID=$(qsub -q all.q -N Moving.Intermediary.Files -hold_jid $WAITID -terse -cwd -b y -o Bismap.FileMov.LOG -e Bismap.FileMov.ERR mv data/TestGenomeMappability/kmers/k100/*bowtie* data/TestGenomeMappability/kmers/k100/TEMPs)
IDPARTS=($(echo $JOBID | tr "." "\n"))
WAITID=${IDPARTS[0]}
echo "Submitted JOB ID $WAITID"

JOBID=$(qsub -q all.q -t 1-2513 -N Bismap.UniqueKmers -terse -tc 120 -hold_jid $WAITID -cwd -b y -o data/TestGenomeMappability/kmers/Bismap.UniqueKmers.LOG -e data/TestGenomeMappability/kmers/Bismap.UniqueKmers.ERR python get_kmers.py data/TestGenomeMappability/chrsize.tsv data/TestGenomeMappability/kmers/k150 data/TestGenomeMappability/chrs data/TestGenomeMappability/chrsize_index.tsv --var_id SGE_TASK_ID --kmer k150)
IDPARTS=($(echo $JOBID | tr "." "\n"))
WAITID=${IDPARTS[0]}
echo "Submitted JOB ID $WAITID"

JOBID=$(qsub -q all.q -t 1-2513 -N Bismap.RunBowtie -terse -tc 120 -hold_jid $WAITID,$WAITID -cwd -b y -o data/TestGenomeMappability/kmers/Bismap.RunBowtie.LOG -e data/TestGenomeMappability/kmers/Bismap.RunBowtie.ERR python run_bowtie.py data/TestGenomeMappability/kmers/k150  data/TestGenomeMappability/genome Umap_bowtie.ind -var_id SGE_TASK_ID)
IDPARTS=($(echo $JOBID | tr "." "\n"))
WAITID=${IDPARTS[0]}
echo "Submitted JOB ID $WAITID"

JOBID=$(qsub -q all.q -t 1-29:1 -N Bismap.UnifyBowtie -terse -tc 120 -hold_jid $WAITID -cwd -b y -o data/TestGenomeMappability/kmers/Bismap.UnifyBowtie.LOG -e data/TestGenomeMappability/kmers/Bismap.UnifyBowtie.ERR python unify_bowtie.py data/TestGenomeMappability/kmers/k150 data/TestGenomeMappability/chrsize.tsv -var_id SGE_TASK_ID)
IDPARTS=($(echo $JOBID | tr "." "\n"))
WAITID=${IDPARTS[0]}
echo "Submitted JOB ID $WAITID"

JOBID=$(qsub -q all.q -N Moving.Intermediary.Files -hold_jid $WAITID -terse -cwd -b y -o Bismap.FileMov.LOG -e Bismap.FileMov.ERR mv data/TestGenomeMappability/kmers/k150/*kmer* data/TestGenomeMappability/kmers/k150/TEMPs)
IDPARTS=($(echo $JOBID | tr "." "\n"))
WAITID=${IDPARTS[0]}
echo "Submitted JOB ID $WAITID"

JOBID=$(qsub -q all.q -N Moving.Intermediary.Files -hold_jid $WAITID -terse -cwd -b y -o Bismap.FileMov.LOG -e Bismap.FileMov.ERR mv data/TestGenomeMappability/kmers/k150/*bowtie* data/TestGenomeMappability/kmers/k150/TEMPs)
IDPARTS=($(echo $JOBID | tr "." "\n"))
WAITID=${IDPARTS[0]}
echo "Submitted JOB ID $WAITID"

JOBID=$(qsub -q all.q -N CombineUmappedFiles -terse -t 1-29 -hold_jid $WAITID -cwd -b y -o data/TestGenomeMappability/kmers/Bismap.combine.LOG -e data/TestGenomeMappability/kmers/Bismap.combine.ERR python combine_umaps.py data/TestGenomeMappability/kmers data/TestGenomeMappability/chrsize.tsv -var_id SGE_TASK_ID)
IDPARTS=($(echo $JOBID | tr "." "\n"))
WAITID=${IDPARTS[0]}
echo "Submitted JOB ID $WAITID"
