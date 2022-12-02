for file in {1..29}
do
  echo $file
  wget -c https://ftp.ensembl.org/pub/release-108/fasta/salmo_salar/dna/Salmo_salar.Ssal_v3.1.dna_sm.primary_assembly.$file.fa.gz
done
