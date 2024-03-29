## Installation and running umap and blacklist packages for ChIP-seq

The whole process of installation and execution of umap and Blacklist was excruciating, to put it mildly, and took solid three weeks. I thought jotting down the whole process of creating blacklist region file might be useful for anyone trying their hands on ChIP-seq analysis with non-standard genomes. This document describes how to install and run the two packages 'umap' and 'Blacklist' to generate blacklist region file for ChIP-seq analysis. Good luck!

---

### Part 1: Installation

#### Install umap
umap is available [on github](https://github.com/hoffmangroup/umap) but I would strongly advise install using [conda](https://anaconda.org/bioconda/umap) (because it requires some old builds and dependencies, e.g. python2.7 and bowtie1).
\
\
Create new conda environment umap_env & install umap with all dependencies.
\
\
`conda create -n umap_env umap`

```ruby
The following NEW packages will be INSTALLED:

bowtie             bioconda/linux-64::bowtie-1.1.2-py27_2
.
.
.
numpy              conda-forge/linux-64::numpy-1.16.5-py27h95a1406_0
pandas             conda-forge/linux-64::pandas-0.24.2-py27hb3f55d8_0
pip                conda-forge/noarch::pip-20.1.1-pyh9f0ad1d_0
python             conda-forge/linux-64::python-2.7.15-h5a48372_1011_cpython

# To activate this environment, use
#
#     $ conda activate umap_env
#
# To deactivate an active environment, use
#
#     $ conda deactivate

```
---

#### Compile Blacklist
Blacklist can be installed using [conda](https://anaconda.org/bioconda/encode-blacklist) too, but (I think) it strictly requires one of the mappability kmers  of size <=36, therefore, if you don't have kmer mappability data for 36, the Blacklist would seemingly run fine but will spit out [entire chr as high signal region](https://github.com/Boyle-Lab/Blacklist/issues/32). The only way to circumvent this is to edit line 149 of the blacklist.cpp [file](https://github.com/Boyle-Lab/Blacklist/blob/master/blacklist.cpp) to one of the kmers you used to create mappability files, prior to 'build & make' manually.
\
\
For example, if my ChIP-seq read length is 150, and I created mappability files with kmers 100 150, the default conda-installed Blacklist wouldn't work. To make this work, I need to [edit](https://github.com/Boyle-Lab/Blacklist/issues/32) line 149 in the blacklist.cpp file prior to build & make.\
from `int uniqueLength = 36; //This is arbitraty and defines how long a read needs`\
to `int uniqueLength = 100; //This is arbitraty and defines how long a read needs`
\
\
Here is how I compiled the Blacklist package manually.
```ruby
module load phys/compilers/gcc/9.4.0
module load igmm/apps/cmake/3.12.2
git clone https://github.com/Boyle-Lab/Blacklist.git
cd Blacklist/
rm bamtools/ -r        # bamtools directory is empty, need to remove and clone it afresh
git clone https://github.com/pezmaster31/bamtools.git
cd bamtools/
mkdir build
```
Before compiling the source code, make sure you have edited the line 149 in the blacklist.cpp to the desired length.
```ruby
cd build
cmake -DCMAKE_INSTALL_PREFIX:PATH=$(cd ..; pwd)/install ..
make
make install
cd ../..
make
```
It threw this error:
```
g++ -std=c++14 -o Blacklist blacklist.cpp -I/exports/eddie/scratch/pdewari/test_black/Blacklist/bamtools/install/include/bamtools -L/exports/eddie/scratch/pdewari/test_black/Blacklist/bamtools/install/lib/bamtools -lbamtools -lz -Wl,-rpath,/exports/eddie/scratch/pdewari/test_black/Blacklist/bamtools/install/lib/bamtools
blacklist.cpp: In function ‘int getdir(std::string, std::vector<std::__cxx11::basic_string<char> >&, std::string)’:
blacklist.cpp:186:1: warning: control reaches end of non-void function [-Wreturn-type]
186 | }
| ^
/usr/bin/ld: cannot find -lbamtools
collect2: error: ld returned 1 exit status
make: *** [all] Error 1
```
Reason being, bamtools library `libbamtools` is getting installed somewhere different from where the blacklist makefile expects it.\
I can see that it's installed in `bamtools/install/lib64/`\
All we need to do is change line 4 in the [./Blacklist/Makefile](https://github.com/Boyle-Lab/Blacklist/blob/master/Makefile)\
from`BAMTOOLS_LIB_DIR=$(prefix)/bamtools/install/lib/bamtools`\
to`BAMTOOLS_LIB_DIR=$(prefix)/bamtools/install/lib64`\
\
Re-run `make`
```ruby
make
g++ -std=c++14 -o Blacklist blacklist.cpp -I/exports/eddie/scratch/pdewari/test_black/Blacklist/bamtools/install/include/bamtools -L/exports/eddie/scratch/pdewari/test_black/Blacklist/bamtools/install/lib64 -lbamtools -lz -Wl,-rpath,/exports/eddie/scratch/pdewari/test_black/Blacklist/bamtools/install/lib64
blacklist.cpp: In function ‘int getdir(std::string, std::vector<std::__cxx11::basic_string<char> >&, std::string)’:
blacklist.cpp:186:1: warning: control reaches end of non-void function [-Wreturn-type]
  186 | }
      | ^ 
```
Throws a warning (which we can ignore) but can see that a new executable Blacklist file has been successfully created :+1:.
```ruby
ls
bamtools  Blacklist  blacklist.cpp  demo  LICENSE  lists  Makefile  README.md
# also, you could just mock run the Blacklist executable, see below
./Blacklist 
```
This would throw a warning/help as follows:
\
Blacklist is used to generate the ENCODE blacklists for various species. \
Usage is ./Blacklist \<chr>
\
The program requires an input/ folder containing indexed bam files. \
The program requires a mappability/ folder containing Umap mappability files.

---


### Part 2: Quick test run

#### Running umap

```ruby
conda activate umap_env
git clone https://github.com/hoffmangroup/umap.git
cd umap
python setup.py install  # need to do this only once

cd umap
python ubismap.py -h
python ubismap.py data/genome.fa data/chrsize.tsv data/TestGenomeMappability all.q $BOWTIEDIR/bowtie-build --kmer 8 12 -write_script test_run.sh
```
The command above should output this:
```
120 Jobs will be run simultaneously at each step
Started copying/reverse complementing/converting
Umap genome is being processed
Reverse complementation: False
Nucleotide conversion: None

>chr1 started at 2022-12-01 15:20:32.753554
ATCGAATCGAATCGAATCGAATCGAATCGA

>chr2 started at 2022-12-01 15:20:32.755993
Indexing the genome started at 2022-12-01 15:20:32.756344
job id $WAITID from indexing genome
Done with indexing at 2022-12-01 15:20:32.758889
Jobs submitted for k8
Jobs submitted for k12
Successfully done with creating all jobs
```
The command above creates a test_run.sh file with all job details that you need to submit via the command below.
```
sh test_run.sh
```
I do not have SGE on my University server, so the job submission is declined, and gives me this error
```
Unable to run job: Job was rejected because job requests unknown queue "all.q".
Exiting.
Submitted JOB ID 
Unable to run job: Job was rejected because job requests unknown queue "all.q".
Exiting.
Submitted JOB ID 
qsub: ERROR! Wrong jid_hold list format "," specified to -hold_jid option
Submitted JOB ID 
Unable to run job: Job was rejected because job requests unknown queue "all.q".
Exiting.
```
To circumvent this, all we have to do is edit the file using `nano test_run.sh` and remove the `-q all.q` occurrences in the code.
Please do note that when you use conda environment (such as `conda activate umap_env` above), `bowtie` can be run from any location, so you will have to edit the test_run.sh for bowtie-build location\
change `/bowtie-build` to `bowtie-build`\
If you don't make the change above, bowtie indexing would fail!! After making these changes, submit jobs via command below.
```
sh test_run.sh

Submitted JOB ID 25942530
Submitted JOB ID 25942531
Submitted JOB ID 25942532
Submitted JOB ID 25942533
Submitted JOB ID 25942534
Submitted JOB ID 25942535
Submitted JOB ID 25942536
Submitted JOB ID 25942537
Submitted JOB ID 25942539
Submitted JOB ID 25942540
Submitted JOB ID 25942541
Submitted JOB ID 25942542
```
If queuing on server is horrible or for some reason it can't run bowtie-build\
(`cat data/TestGenomeMappability/genome/index/index_genome.ERR`), best is to run each job on terminal by pasting the code below, rather than via `sh test_run.sh`\

```ruby
bowtie-build data/TestGenomeMappability/genome/genome.fa data/TestGenomeMappability/genome/Umap_bowtie.ind

#should output something like this
Getting block 7 of 7
  Reserving size (28) for bucket
  Calculating Z arrays
  Calculating Z arrays time: 00:00:00
  Entering block accumulator loop:
  10%
  20%
  30%
  40%
  50%
  60%
  70%
  80%
  90%
  100%
  Block accumulator loop time: 00:00:00
```
---

### Part 3: Create mappability files for atlantic salmon Ssal_v3.1 (GCA_905237065.2)

See detailed documentation [here](https://github.com/Pooran-Dewari/umap-and-blacklist-ChIP-seq/blob/main/Run%20umap%20Atlantic%20salmon.md)

---

### Part 4: Create blacklist bed file for atlantic salmon Ssal_v3.1 (GCA_905237065.2)

See detailed documentation [here](https://github.com/Pooran-Dewari/umap-and-blacklist-ChIP-seq/blob/main/Run%20Blacklist%20Atlantic%20salmon.md)
