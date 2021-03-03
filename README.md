# nf-LO
## Nextflow LiftOver pipeline

## Introduction
*nf-LO* is a nextflow implementation of the UCSC liftover pipeline. It comes with a series of presets, allowing alignments of genomes depending on their distance (near, medium and far). It also supports four different aligners ([lastz](https://github.com/UCSantaCruzComputationalGenomicsLab/lastz), [blat](https://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/blat/), [minimap2](https://github.com/lh3/minimap2), [GSAlign](https://github.com/hsinnan75/GSAlign)), providing solutions for  both different-species (lastz and minimap2) as well as same-species alignments (blat and GSAlign), with both standard and ultra-fast algorithms from a source to a target genome.  

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
 5. [GSAlign](https://github.com/hsinnan75/GSAlign)
 6. [CrossMap](http://crossmap.sourceforge.net/)
 7. [Graphviz](https://graphviz.org/)
 8. Many exe from the [kent toolkit](https://github.com/ucscGenomeBrowser/kent): 
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

Ready to go!


## Input genomes
Source and target genomes can be either a local or remote (un)compressed fasta file. Source genome is the genome of origin, from which lift the positions. Target genome is the genome *to* which lift the position. 
We recommend to use soft-masked genomes to reduce computation time for aligners such as lastz. If the genome is unmasked, we provide [nf-RM](https://www.github.com/RenzoTale88/nf-RM.git), a pipeline to perform repetitive element masking of genomes. 

### Download from NCBI
*nf-LO* can download from ncbi directly using the [datasets](https://www.ncbi.nlm.nih.gov/datasets/docs/command-line-start/) software. Users can provide a GCA/GCF codes instead of the input, and specify that is a ncbi download with the flags `--ncbi_source` and `--ncbi_target` as follow:
```
nextflow run evotools/nf-LO --source GCF_001549955.1 --target GCF_011751205.1 --ncbi_source --ncbi_target -profile local,test -r 1.5.0
```
The workflow will download the [datasets](https://www.ncbi.nlm.nih.gov/datasets/docs/command-line-start/) utility locally and use it to retrieve the genomes.


## Running the pipeline
To test the pipeline locally, simply run:
```
nextflow run evotools/nf-LO -r 1.5.0 -profile test,docker
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
    -profile docker -r 1.5.0 
```
This analysis will run using genome1 and genome2 as source and target, respectively. The source genome will be fragmented in chunks of 20Mb, 
whereas the target will be fragmented in 10Mb chunks overlapping 100Kb. It will use lastz as aligner using the preset for closely related genomes (near).
The output files will be copied into the folder my_liftover.

## Distance 
The workflow will provide some custom configuration for the different software used. The preset available are the following:


|   Aligner |       Preset      |   Aligner settings    |   axtChain    |
|-----------|-------------------|-----------------------|---------------|
| lastz     |       near        | B=0 C=0 E=150 H=0 K=4500 L=3000 M=254 O=600 T=2 Y=15000 | -minScore=5000 -linearGap=medium |
|           |       medium      | B=0 C=0 E=30 H=0 K=3000 L=3000 M=50 O=400 T=1 Y=9400  | -minScore=3000 -linearGap=medium |
|           |       far         | B=0 C=0 E=30 H=2000 K=2200 L=6000 M=50 O=400 T=2 Y=3400  | -minScore=5000 -linearGap=loose |
| blat      |       near        | -t=dna -q=dna -fastMap -noHead -tileSize=11 -minScore=100 -minIdentity=98 | -minScore=5000 -linearGap=medium |
|           |       medium      | -t=dna -q=dna -fastMap -noHead -tileSize=11 -stepSize=11 -oneOff=0 -minMatch=2 -minScore=30 -minIdentity=90 -maxGap=2 -maxIntron=75000 | -minScore=3000 -linearGap=medium |
|           |       far         | -t=dna -q=dna -fastMap -noHead -tileSize=12 -oneOff=1 -minMatch=1 -minScore=30 -minIdentity=80 -maxGap=3 -maxIntron=75000 | -minScore=5000 -linearGap=loose |
|           |       balanced    | -fastMap -tileSize=12 -minIdentity=98 |   -minScore=5000 -linearGap=medium    |
| minimap2  |       near        | -cx asm5 | -minScore=5000 -linearGap=medium |
|           |       medium      | -cx asm10 | -minScore=3000 -linearGap=medium |
|           |       far         | -cx asm20 | -minScore=5000 -linearGap=loose |
| GSAlign   |       near        | -sen -idy 80 | -minScore=5000 -linearGap=medium |
|           |       medium      | -sen -idy 75 | -minScore=3000 -linearGap=medium |
|           |       far         | -sen -idy 70 | -minScore=5000 -linearGap=loose |
|           |       same        | -sen | -minScore=5000 -linearGap=medium |

# References
Adaptive seeds tame genomic sequence comparison. Kiełbasa SM, Wan R, Sato K, Horton P, Frith MC. Genome Res. 2011 21(3):487-93; http://dx.doi.org/10.1101/gr.113985.110

Harris, R.S. (2007) Improved pairwise alignment of genomic DNA. Ph.D. Thesis, The Pennsylvania State University

Li, H. (2018). Minimap2: pairwise alignment for nucleotide sequences. Bioinformatics, 34:3094-3100. http://dx.doi.org/10.1093/bioinformatics/bty191

Kent WJ. BLAT - the BLAST-like alignment tool. Genome Res. 2002 Apr;12(4):656-64

Zhao, H., Sun, Z., Wang, J., Huang, H., Kocher, J.-P., & Wang, L. (2013). CrossMap: a versatile tool for coordinate conversion between genome assemblies. Bioinformatics (Oxford, England), btt730

Lin, HN., Hsu, WL. GSAlign: an efficient sequence alignment tool for intra-species genomes. BMC Genomics 21, 182 (2020). https://doi.org/10.1186/s12864-020-6569-1
