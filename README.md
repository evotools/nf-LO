# nf-LO
## Nextflow LiftOver pipeline

## Introduction
*nf-LO* is a nextflow implementation of the UCSC liftover pipeline. It comes with a series of presets, allowing alignments of genomes depending on their distance (near, medium and far). It also supports three different aligner ([lastz](https://github.com/UCSantaCruzComputationalGenomicsLab/lastz), [blat](https://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/blat/), [minimap2](https://github.com/lh3/minimap2) and [last](http://last.cbrc.jp/)), therefore providing different-species (lastz), same-species (blat) and ultra-fast liftovers from a source to a target genome.  

## Dependencies
### Nextflow
Nextflow needs to be installed and in your path to be able to run the pipeline. 
To do so, follow the instructions [here](https://www.nextflow.io/)

### Profiles
*nf-LO* comes with a series of pre-defined profiles:
 - standard: this profile runs all dependencies in docker and other basic presets to facilitate the use
 - local: runs using local exe instead of containerized/conda dependencies (see manual installation for further details)
 - docker: force the use of docker 
 - singularity: runs the dependencies within singularity
 - conda: runs the dependencies within conda
 - uge: runs using UGE scheduling system
 - sge: runs using SGE scheduling system
A docker image is available with all the dependencies at tale88/nf-lo. This docker ships all necessary dependencies to run nf-LO. 
This is the recommended mode of usage of the software, since all the dependencies come shipped in the container.

### Manual installation
In the case the system doesn't support docker/singularity, it is possible to download them all through the script install.sh.
This script will download a series of software and save them in the ./bin folder, including:
 1. [lastz](https://github.com/UCSantaCruzComputationalGenomicsLab/lastz)
 2. [blat](https://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/blat/)
 3. [minimap2](https://github.com/lh3/minimap2)
 4. [last](http://last.cbrc.jp/)
 6. Many exe from the [kent toolkit](https://github.com/ucscGenomeBrowser/kent): 
    - axtChain
    - chainAntiRepeat
    - chainMergeSort
    - chainNet
    - chainPreNet
    - chainStitchId
    - chainSplit
    - faSplit
    - faToTwoBit
    - liftOver
    - liftUp
    - netChainSubset
    - netSyntenic
    - twoBitInfo
    - lavToPsl
Remember to add the ```bin``` folder to your path with the command:
```
export PATH=$PATH:$PWD/bin
```
Or link te folder to the working directory:
```
ln -s /PATH/TO/bin
```

Ready to go!


## Running the pipeline
To test the pipeline locally, simply run:
```
nextflow run RenzoTale88/nf-LO 
    --distance near \
    --aligner lastz \
    --tgtSize 2000000 \
    --srcSize 1000000 \
    --srcOvlp 100000 \
    -profile test,docker
```
This will download and run the pipeline on the two toy genomes provided and generate liftover files. If you have all dependencies installed locally
you can omit ```docker``` from the profile configuration.

# References
Adaptive seeds tame genomic sequence comparison. Kiełbasa SM, Wan R, Sato K, Horton P, Frith MC. Genome Res. 2011 21(3):487-93; http://dx.doi.org/10.1101/gr.113985.110
Harris, R.S. (2007) Improved pairwise alignment of genomic DNA. Ph.D. Thesis, The Pennsylvania State University
Li, H. (2018). Minimap2: pairwise alignment for nucleotide sequences. Bioinformatics, 34:3094-3100. http://dx.doi.org/10.1093/bioinformatics/bty191
Kent WJ. BLAT - the BLAST-like alignment tool. Genome Res. 2002 Apr;12(4):656-64