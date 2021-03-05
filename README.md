# nf-LO
## Nextflow LiftOver pipeline

## Introduction
*nf-LO* is a [nextflow](https://www.nextflow.io/) workflow for generating genome alignment files compatible with the UCSC [liftOver](https://genome.ucsc.edu/cgi-bin/hgLiftOver) utility for converting genomic coordinates between assemblies. It can automatically pull genomes directly from NCBI or iGenomes (or the user can provide fasta files) and supports four different aligners ([lastz](https://github.com/UCSantaCruzComputationalGenomicsLab/lastz), [blat](https://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/blat/), [minimap2](https://github.com/lh3/minimap2), [GSAlign](https://github.com/hsinnan75/GSAlign)). Together these provide solutions for both different-species (lastz and minimap2) as well as same-species alignments (blat and GSAlign), with both standard and ultra-fast algorithms from a source to a target genome. It comes with a series of presets, allowing alignments of genomes depending on their genomic distance (near, medium and far). 

## Quick start

Nextflow first needs to be installed. 
To do so, follow the instructions [here](https://www.nextflow.io/)
```
curl -s https://get.nextflow.io | bash
```
Note Nextflow requires Java 8 or later.

To then run the nf-LO workflow to align the S. cerevisiae and S. pombe genomes pulled directly from [iGenomes](https://emea.support.illumina.com/sequencing/sequencing_software/igenome.html):
```
./nextflow run evotools/nf-LO --igenome_target sacCer3 --igenome_source EF2 --distance far --aligner minimap2 -profile singularity -latest --outdir ./my_liftover_minimap2
```
This command will use singularity to obtain the required dependencies and output a chain file compatible with the liftOver utility to the my_liftover_minmap2 folder. See below for more information on how to alternatively use docker, or to manually install the required tools.

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
 5. [GSAlign](https://github.com/hsinnan75/GSAlign)
 6. [CrossMap](http://crossmap.sourceforge.net/)
 7. [Graphviz](https://graphviz.org/)
 8. Many .exe files from the [kent toolkit](https://github.com/ucscGenomeBrowser/kent): 
    1. axtChain
    2. chainAntiRepeat
    3. chainMergeSort
    4. chainNet
    5. chainPreNet
    6. chainStitchId
    7. chainSplit
    8. faSplit
    9. faToTwoBit
    10. liftOver
    11. liftUp
    12. netChainSubset
    13. netSyntenic
    14. twoBitInfo
    15. lavToPsl
    
Remember to add the ```bin``` folder to your path with the command:
```
export PATH=$PATH:$PWD/bin
```
Or link te folder to the working directory:
```
ln -s /PATH/TO/bin
```


## Input genomes

There are three different ways a user can specify genomes to align. Note in each case the source genome is the genome of origin, from which you which to lift the positions. The target genome is the genome *to* which you wish to lift the positions to. 
We recommend to use soft-masked genomes to reduce the computation time for aligners such as lastz. 

### 1. User provided fasta
The source and target genomes can be specified as local or remote (un)compressed fasta files using the `--source` and `--target` flags. 
### 2. Automatically download from NCBI
*nf-LO* can download fasta files from ncbi directly. Users provide a GCA/GCF code using the `--ncbi_source` and `--ncbi_target` flags as follow:
```
nextflow run evotools/nf-LO --ncbi_source GCF_001549955.1 --ncbi_target GCF_011751205.1 -profile local,test
```
### 3. Automatically download from iGenomes
*nf-LO* can also download genomes from the [iGenomes](https://emea.support.illumina.com/sequencing/sequencing_software/igenome.html) site. To do this users provide a genome identifier with the `--igenome_source` and `--igenome_target` flags as follow:
```
nextflow run evotools/nf-LO --igenome_source equCab2 --target igenome_dm6 -profile local,test
```

Note it is possible to mix source and target flags. For example using `--igenome_source` with `--ncbi_target`.


## Further examples for running the pipeline
To test the pipeline locally, simply run:
```
nextflow run evotools/nf-LO -profile test,docker
```
This will download and run the pipeline on the two toy genomes provided and generate liftover files. If you have all dependencies installed locally
you can omit ```docker``` from the profile configuration.

Alternatively, you can run it on your own genomes using a command like this:
```
nextflow run evotools/nf-LO \
    --source genome1 \
    --target genome2 \
    --annotation myfile.gff \
    --annotation_format gff \
    --distance near \
    --aligner lastz \
    --tgtSize 10000000 \
    --tgtOvlp 100000 \
    --srcSize 20000000 \
    --liftover_algorithm crossmap \
    --outdir ./my_liftover \
    --publish_dir_mode copy \
    -profile docker 
```
This analysis will run using genome1 and genome2 as source and target, respectively. The source genome will be fragmented in chunks of 20Mb, 
whereas the target will be fragmented in 10Mb chunks overlapping 100Kb. It will use lastz as the aligner using the preset for closely related genomes (near).
The output files will be copied into the folder my_liftover.

## Distance 
The workflow will provide some custom configuration for the different algorithms and distances. 
**NOTE**: the alignment stage heavily affects the results of the chaining process, so we strongly recommend to perform different tests with different configurations, including custom ones.
To see the presets available and how to fine-tune the pipeline go to our [Alignments](https://github.com/evotools/nf-LO/wiki/Alignments) wiki page.
The chain/net generation can also be fine-tuned to achieve better results (see [Chain/Netting](https://github.com/evotools/nf-LO/wiki/Chain-Netting)).

# References
Adaptive seeds tame genomic sequence comparison. Kiełbasa SM, Wan R, Sato K, Horton P, Frith MC. Genome Res. 2011 21(3):487-93; http://dx.doi.org/10.1101/gr.113985.110

Harris, R.S. (2007) Improved pairwise alignment of genomic DNA. Ph.D. Thesis, The Pennsylvania State University

Li, H. (2018). Minimap2: pairwise alignment for nucleotide sequences. Bioinformatics, 34:3094-3100. http://dx.doi.org/10.1093/bioinformatics/bty191

Kent WJ. BLAT - the BLAST-like alignment tool. Genome Res. 2002 Apr;12(4):656-64

Zhao, H., Sun, Z., Wang, J., Huang, H., Kocher, J.-P., & Wang, L. (2013). CrossMap: a versatile tool for coordinate conversion between genome assemblies. Bioinformatics (Oxford, England), btt730

Lin, HN., Hsu, WL. GSAlign: an efficient sequence alignment tool for intra-species genomes. BMC Genomics 21, 182 (2020). https://doi.org/10.1186/s12864-020-6569-1
