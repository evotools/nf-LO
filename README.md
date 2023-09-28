# nf-LO
[![CI](https://github.com/evotools/nf-LO/actions/workflows/CI.yml/badge.svg)](https://github.com/evotools/nf-LO/actions/workflows/CI.yml) [![Docker](https://github.com/evotools/nf-LO/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/evotools/nf-LO/actions/workflows/docker-publish.yml) [![Singularity Build (docker)](https://github.com/evotools/nf-LO/actions/workflows/singularity.yml/badge.svg)](https://github.com/evotools/nf-LO/actions/workflows/singularity.yml) [![Python Package using Conda](https://github.com/evotools/nf-LO/actions/workflows/conda.yml/badge.svg)](https://github.com/evotools/nf-LO/actions/workflows/conda.yml)

## Nextflow LiftOver pipeline
*nf-LO* is a [nextflow](https://www.nextflow.io/) workflow for generating genome alignment files compatible with the UCSC [liftOver](https://genome.ucsc.edu/cgi-bin/hgLiftOver) utility for converting genomic coordinates between assemblies. It can automatically pull genomes directly from NCBI or iGenomes (or the user can provide fasta files) and supports four different aligners ([lastz](https://github.com/UCSantaCruzComputationalGenomicsLab/lastz), [blat](https://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/blat/), [minimap2](https://github.com/lh3/minimap2), [GSAlign](https://github.com/hsinnan75/GSAlign)). Together these provide solutions for both different-species (lastz and minimap2) as well as same-species alignments (blat and GSAlign), with both standard and ultra-fast algorithms from a source to a target genome. It comes with a series of presets, allowing alignments of genomes depending on their genomic distance (near, medium and far). 

# Updates
**UPDATE 27/09/2023**: The `--aligner minimap2` mode now runs in multiple processes, splitting the target genome in fragments of at least `--tgtSize` bases; individual contigs and scaffolds **will not be fragmented**, and each chunk will contain entire sequences. The old approach is still accessible through the `--full_alignment` option.

**UPDATE 14/12/2022**: Now the NCBI/iGenomes accession have to be provided in the `--source`/`--target` field, and then use the appropriate `--igenomes_source`/`--ncbi_source` and `--igenomes_target`/`--ncbi_target` as a modifier.

**UPDATE 08/06/2022**: fixed a bug in which lastz would not align small fragmented genomes, as well as small contigs, in the source assembly. Anyone interested in these small contigs should discard the previous version of `nf-LO` using `nextflow drop evotools/nf-LO`, and repeat the analyses.

**UPDATE 07/06/2022**: Added the possibility of providing customized conservation scores in the q-format via the `--qscores` flag.


## Documentation
You can find more details on the usage of *nf-LO* in the [readthedocs](https://nf-lo.readthedocs.io/en/latest/) or in the [wiki](https://github.com/evotools/nf-LO/wiki) pages. These also include a simple [step-by-step](https://nf-lo.readthedocs.io/en/latest/step.html) tutorial to run the analyses on your own genomes.

## Table of Contents

- [Installation](#Installation)
- [Quick start](#Quick-start)
- [Profiles](#Profiles)
- [Inputs](#Inputs)
  - [Custom fasta](#Custom-fasta)
  - [Download from NCBI](#Download-from-NCBI)
  - [Download from iGenomes](#Download-from-iGenomes)
- [Customize the run](#Customize-the-run)
- [Resources](#Resources) 
- [Example](#Example)
- [Citing](#Citing-nf-LO)
- [References](#References)

## Installation
Nextflow first needs to be installed. 
To do so, follow the instructions [here](https://www.nextflow.io/)
```
curl -s https://get.nextflow.io | bash
```
Note Nextflow requires Java 8 or later.
We suggest to install, depending on your preferences:
 - [anaconda](https://www.anaconda.com/products/individual)
 - [docker](https://www.docker.com/)
 - [singularity](https://sylabs.io/)

The workflow natively support four different ways to provide dependencies:
1. Anaconda: this is the recommended and easiest way.
2. Docker: you can create a docker image locally by using the `Dockerfile` and `environment.yml` files in the folder
3. Singularity: you can create a singularity sif image locally by using the `singularity.def` and `environment.yml` files in the folder
4. Local installation: we provide an `assets/install.sh` script that will take care of installing all the dependencies.

Using anaconda is the easiest to run almost all components of the workflow, the only exception being [mafTools](https://github.com/dentearl/mafTools).
This can be installed locally using the `assets/install_maftools.sh` script, that will take care of the installation in your linux or macOS machine.
The Singularity and Docker containers contain mafTools.
If you need further information on the installation of the dependencies, you can have a look at the specific [wiki page](https://nf-lo.readthedocs.io/en/latest/install.html)

## Quick start
After obtaining nextflow, to run the nf-LO workflow to align the S. cerevisiae and S. pombe genomes pulled directly from [iGenomes](https://emea.support.illumina.com/sequencing/sequencing_software/igenome.html) simply type:
```
./nextflow run evotools/nf-LO --igenomes_target sacCer3 --igenomes_source EF2 --distance far --aligner minimap2 -profile conda -latest --outdir ./my_liftover_minimap2
```
This command will use anaconda to obtain the required dependencies and output a chain file compatible with the liftOver utility to the my_liftover_minmap2 folder. See below for more information on how to alternatively use docker, or to manually install the required tools.

## Resource management
By default, *nf-LO* will attempt to use all cores available - 1 and the total amount of memory reserved by the java virtual machine. For most installation, it means that the workflow will use up to 3.GB of memory and almost all cores accessible. 
Users can customize these values in case the memory and/or cpus requested are not enough, or if the user is running the workflow on a cluster system.
To do so, users can specify the settings as follow:
 1. `--max_cpus`: maximum number of cpus requested and used by the tasks (e.g. `--max_cpus 4` will use at most 4 cpus for a single job)
 2. `--max_time`: maximum time to use for a single job (e.g. `--max_time 12.h` will run a task for at most 12 hours)
 3. `--max_memory`: maximum memory used by a single job (e.g. `--max_memory 16.GB` will use at most 16 GB of ram for a job)

## Profiles
*nf-LO* comes with a series of pre-defined profiles:
 - standard: this profile runs all dependencies using anaconda
 - local: runs using local exe instead of containerized/conda dependencies (see manual installation for further details)
 - conda: runs the dependencies within conda
 - uge: runs using UGE scheduling system
 - sge: runs using SGE scheduling system
 - Additional profiles: see additional profiles supported [here](http://www.github.com/nf-core/configs)

## Inputs

There are three different ways a user can specify genomes to align. Note in each case the source genome is the genome of origin, from which you which to lift the positions. The target genome is the genome *to* which you wish to lift the positions. 
We recommend to use soft-masked genomes to reduce the computation time for aligners such as lastz. 

### Custom fasta
The source and target genomes can be specified as local or remote (un)compressed fasta files using the `--source` and `--target` flags. 
### Download from NCBI
*nf-LO* can download fasta files from ncbi directly using the [datasets API](https://www.ncbi.nlm.nih.gov/datasets/). Users provide a GCA/GCF code in the `--source`/`--target` field, and add the `--ncbi_source` and `--ncbi_target` flags as follow:
```
nextflow run evotools/nf-LO --source "GCF_001549955.1" --target "GCF_011751205.1" --ncbi_source --ncbi_target  -profile conda 
```
### Download from iGenomes
*nf-LO* can also download genomes from the [iGenomes](https://emea.support.illumina.com/sequencing/sequencing_software/igenome.html) site. Users provide a GCA/GCF code in the `--source`/`--target` field, and add the `--igenomes_source` and `--igenomes_target` flags as follow:
```
nextflow run evotools/nf-LO --source "equCab2" --target "dm6" --igenomes_source --target_igenome -profile conda 
```

Note it is possible to mix source and target flags. For example using `--igenomes_source` with `--ncbi_target`.

## Customize the run 
The workflow will provide some custom configuration for the different algorithms and distances. 
**NOTE**: the alignment stage heavily affects the results of the chaining process, so we strongly recommend to perform different tests with different configurations, including custom ones.
To see the presets available and how to fine-tune the pipeline go to our [Alignments](https://nf-lo.readthedocs.io/en/latest/align.html) wiki page.
The chain/net generation can also be fine-tuned to achieve better results (see [Chain/Netting](https://nf-lo.readthedocs.io/en/latest/chain.html)).

**UPDATE 07/06/2022**: it is now possible to specify customized conservation scores as q files (see [here](http://genomewiki.ucsc.edu/index.php/Hg19_conservation_lastz_parameters) for examples) using the `--qscores` options and providing the correct input file.  

## Resources
If you're running the workflow on a local workstation, single node or a local server we recommend to define the maximum amount of cores and memory for each job.
You can set that using the `--max_memory NCPU` and `--max_cpus 'MEM.GB'`, where NCPU is the maximum number of cpus per task and MEM is the maximum amount of memory for a single task.

## Example
To test the pipeline locally, simply run:
```
nextflow run evotools/nf-LO -profile test,conda
```
This will download and run the pipeline on the two toy genomes provided and generate liftover files. If you have all dependencies installed locally
you can omit ```conda``` from the profile configuration.

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
    --max_cpus 8 \
    --max_memory 32.GB \
    -profile conda 
```
This analysis will run using genome1 and genome2 as source and target, respectively. The source genome will be fragmented in chunks of 20Mb, 
whereas the target will be fragmented in 10Mb chunks overlapping 100Kb. It will use lastz as the aligner using the preset for closely related genomes (near).
The output files will be copied into the folder my_liftover.

## Citing nf-LO
To cite nf-LO, please refer to:
```
nf-LO: A scalable, containerised workflow for genome-to-genome lift over
Andrea Talenti, James Prendergast
Genome Biology and Evolution, 2021;, evab183, https://doi.org/10.1093/gbe/evab183
```

## References
Adaptive seeds tame genomic sequence comparison. Kiełbasa SM, Wan R, Sato K, Horton P, Frith MC. Genome Res. 2011 21(3):487-93; http://dx.doi.org/10.1101/gr.113985.110

Harris, R.S. (2007) Improved pairwise alignment of genomic DNA. Ph.D. Thesis, The Pennsylvania State University

Li, H. (2018). Minimap2: pairwise alignment for nucleotide sequences. Bioinformatics, 34:3094-3100. http://dx.doi.org/10.1093/bioinformatics/bty191

Kent WJ. BLAT - the BLAST-like alignment tool. Genome Res. 2002 Apr;12(4):656-64

Zhao, H., Sun, Z., Wang, J., Huang, H., Kocher, J.-P., & Wang, L. (2013). CrossMap: a versatile tool for coordinate conversion between genome assemblies. Bioinformatics (Oxford, England), btt730

Lin, HN., Hsu, WL. GSAlign: an efficient sequence alignment tool for intra-species genomes. BMC Genomics 21, 182 (2020). https://doi.org/10.1186/s12864-020-6569-1
