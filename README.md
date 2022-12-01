## Installation and running umap and blacklist packages for ChIP-seq

### This document describes how to install and run the two packages 'umap' and 'Blacklist' to generate blacklist region file for ChIP-seq experiments.

#### Install umap
umap is available [on github](https://github.com/hoffmangroup/umap) but I would strongly advise install using [conda](https://anaconda.org/bioconda/umap) (because it requires some old builds and dependencies, e.g. python2.7 and bowtie1).

---

#### Compile Blacklist
Blacklist can be installed using [conda](https://anaconda.org/bioconda/encode-blacklist) too, but (I think) it strictly requires one of the mappability kmers  of size <=36, therefore, if you don't have kmer mappability data for 36, the Blacklist would seemingly run fine but will spit out [entire chr as high signal region](https://github.com/Boyle-Lab/Blacklist/issues/32). The only way to circumvent this is to edit line 149 of the blacklist.cpp [file](https://github.com/Boyle-Lab/Blacklist/blob/master/blacklist.cpp) to one of the kmers you used to create mappability files, prior to 'build & make' manually.
\
\
For example, if my ChIP-seq read length is 150, and I created mappability files with kmers 100 150, the default conda-installed Blacklist wouldn't work. To make this work, I need to edit line 149 in the blacklist.cpp file prior to build & make.\
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
cd Blacklist/bamtools/
mkdir build
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
```
---

### Running umap

