# Installation
## Install nextflow
*nf-LO* is a nextflow workflow, and as such it relies on nextflow to be installed and accessible.
If you need to install nextflow, follow the instructions [here](https://www.nextflow.io/). 
You need to have Java 8 or newer installed, and then install nextflow as follow:
```
curl -s https://get.nextflow.io | bash
```

## Install the dependencies
*nf-LO* uses a series of software to automate and streamline the liftOver generation process.
We provide four different ways to install and run all of these dependencies:
1. [Anaconda](https://www.anaconda.com/products/individual): this is the recommended and easiest way.
2. [Docker](https://www.docker.com/): you can create a docker image locally by using the `Dockerfile` and `environment.yml` files in the folder
3. [Singularity](https://sylabs.io/): you can create a singularity sif image locally by using the `singularity.def` and `environment.yml` files in the folder
4. Local installation: we provide an `install.sh` script that will take care of installing all the dependencies.

The following dependencies are needed to run every component of *nf-LO*:
 1. [lastz](https://github.com/UCSantaCruzComputationalGenomicsLab/lastz)
 2. [blat](https://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/blat/)
 3. [minimap2](https://github.com/lh3/minimap2)
 4. [GSAlign](https://github.com/hsinnan75/GSAlign)
 5. maf-convert from [last](http://last.cbrc.jp/)
 6. [CrossMap](http://crossmap.sourceforge.net/)
 7. [Graphviz](https://graphviz.org/)
 8. Many .exe files from the [kent toolkit](https://hgdownload.soe.ucsc.edu/admin/exe/): 
    1. axtChain
    2. axtToMaf
    3. chainAntiRepeat
    4. chainMergeSort
    5. chainNet
    6. chainPreNet
    7. chainStitchId
    8. chainSplit
    9. chainToAxt
    10. faSplit
    11. faSize
    12. faToTwoBit
    13. lavToPsl
    14. liftOver
    15. liftUp
    16. netChainSubset
    17. netSyntenic
    18. twoBitInfo

Plus the optional dependencies:
1. [mafTools](https://github.com/dentearl/mafTools) (optional)
2. [R](https://cran.r-project.org/) for reporting, with the packages:
   1. tidyverse
   2. Rmarkdown

All dependecies used by *nf-LO* are free for academic, nonprofit and personal use. For commercial use, check the licencing conditions for the different tools separately.

## Anaconda
Almost all dependencies can be installed through anaconda. Follow the instructions [here](https://www.anaconda.com/products/individual) to install anaconda on your machine.
This is the easiest route, since it can be run directly from the github repository:
```
nextflow run evotools/nf-LO -profile test,conda
```
The only dependencies that at this stage cannot be installed with anaconda is [mafTools](https://github.com/dentearl/mafTools). This component is required to generate some of the final metrics of the alignments, and can be installed manually on your macOS or linux machine using the `install_maftools.sh` script. 

## Mamba
To speed up the process, you can install all of the dependencies using [mamba](https://github.com/mamba-org/mamba) instead.
You can take advantage of `mamba` in two possible ways:
1. Use the `--mamba` option
2. Manually installing all the software, and then point to the environment.

To use the first, simply add the `--mamba` option:
```
nextflow run evotools/nf-LO --igenome_source danRer7 --target /PATH/TO/target.fa --mamba -profile conda
```

To manually install the dependencies using `mamba`, first install it in your anaconda environment:
```
conda install -c conda-forge -y mamba
```

Then, create the environment using mamba:
```
mamba env create -f environment.yml
```

This will create a new environment in your anaconda installation folder, that you can then pass to nextflow using the `-with-conda` option:
```
nextflow run evotools/nf-LO -profile test -with-conda `conda info --envs | 'awk $1=="nf-LO" {print $2}'`
```

## Run with docker
The dependencies can be run using docker. Follow the instructions [here](https://docs.docker.com/engine/install/) to install docker on your system. 
The docker image needs to be built locally using the Dockerfile in the folder as follows:
```
curl -O https://raw.githubusercontent.com/evotools/nf-LO/main/Dockerfile
curl -O https://raw.githubusercontent.com/evotools/nf-LO/main/environment.yml
docker build -t nflo:latest .
```

Then, you can run *nf-LO* as follows:
```
nextflow run evotools/nf-LO -profile test -with-docker nflo:latest
```

### Run with singularity
You can run the workflow using a singularity container. Follow the instructions here to install [singularity](https://sylabs.io/guides/3.7/admin-guide/installation.html).
Then, you need to build it first using the command:
```
curl -O https://raw.githubusercontent.com/evotools/nf-LO/main/singularity.def
curl -O https://raw.githubusercontent.com/evotools/nf-LO/main/environment.yml
singularity build nflo.sif singularity.def
```

Then, you can run the workflow as follows:
```
nextflow run evotools/nf-LO -profile test -with-singularity ${PWD}/nflo.sif
```

## Manual installation
This is the case if the system doesn't support docker, singularity or anaconda.
It is possible to download all the dependencies through the script `install.sh`. 
The script will download all the dependencies in a local bin folder:
```
wget https://raw.githubusercontent.com/evotools/nf-LO/main/install.sh
chmod a+x ./install.sh
./install.sh
export PATH=$PATH:${PWD}/bin
```

This code will install all the dependencies in the `bin` folder, that will be automatically added to the path at run time.
