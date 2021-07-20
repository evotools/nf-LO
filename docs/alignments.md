# Alignments
This section documents the parameters for the alignments performed in nf-LO

## Select the aligner
nf-LO currently supports 4 different aligners:
1. [blat](https://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/blat/)
2. [lastz](https://github.com/UCSantaCruzComputationalGenomicsLab/lastz)
3. [minimap2](https://github.com/lh3/minimap2)
4. [GSAlign](https://github.com/hsinnan75/GSAlign)

The first two are the "classic" ones used to generate lift overs, whereas the other two are ultra-fast aligners.
Each has separate characteristics that makes them suitable for different use-cases. 
However, keep in mind that the ultimate choice is yours to make, so consider testing different configurations and aligners! :)

## Same-species lift overs
A same species lift over involves two genomes from the same species. For example, it can be used to map position from an old genome release to a newer one (e.g. HG19 to HG38) or vice-versa if needed. Alternatively, between assemblies for two different individuals.
For these purposes, blat and GSAlign are the two recommended choices due to a higher sensitivity of alignments.

## Different species lift overs
Different species lift over involves two genomes of individuals belonging to two different species. It can be used to map genomic regions and variants that are syntenic between two closely as well as distantly related organisms. The generation of different species lift overs can be heavily affected by the parameters used to align the genomes, so we recommend to perform different tests to define the right combination of speed and sensitivity.
For this purpose, lastz and minimap2 are the two recommended choices.

## Presets
The workflow comes with a series of presets that the users can apply to their datasets directly. The list of presets for each aligner, and their associated parameters, is reported in the table below:


|   Aligner |       Preset      |   Aligner settings    |
|-----------|-------------------|-----------------------|
| lastz     |       near        | B=0 C=0 E=150 H=0 K=4500 L=3000 M=254 O=600 T=2 Y=15000 |
|           |       medium      | B=0 C=0 E=30 H=0 K=3000 L=3000 M=50 O=400 T=1 Y=9400  |
|           |       far         | B=0 C=0 E=30 H=2000 K=2200 L=6000 M=50 O=400 T=2 Y=3400  |
|           |      primate      | E=30 H=3000 K=5000 L=5000 M=10 O=400 T=1  |
|           |      general      | E=30 H=3000 K=5000 L=5000 M=10 O=400 T=1  |
| blat      |       near        | -t=dna -q=dna -fastMap -noHead -tileSize=11 -minScore=100 -minIdentity=98 |
|           |       medium      | -t=dna -q=dna -fastMap -noHead -tileSize=11 -stepSize=11 -oneOff=0 -minMatch=2 -minScore=30 -minIdentity=90 -maxGap=2 -maxIntron=75000|
|           |       far         | -t=dna -q=dna -fastMap -noHead -tileSize=12 -oneOff=1 -minMatch=1 -minScore=30 -minIdentity=80 -maxGap=3 -maxIntron=75000 |
|           |       balanced    | -fastMap -tileSize=12 -minIdentity=98 |
| minimap2  |       near        | -cx asm5 |
|           |       medium      | -cx asm10 |
|           |       far         | -cx asm20 |
| GSAlign   |       near        | -sen -idy 80 |
|           |       medium      | -sen -idy 75 |
|           |       far         | -sen -idy 70 |
|           |       same        | -sen |

Presets for near, medium and far lastz aligner can be found [here](https://github.com/ENCODE-DCC/kentUtils/blob/master/src/hg/utils/automation/runLastzChain.sh). The parameters for lastz's primate and general are defined in the [ensembl compara pairwise genome alignments](https://m.ensembl.org/info/genome/compara/analyses.html). The general pre-set is applied to alignments, for example, of human and chicken or human and mouse. The primate is used for human to chimp, for example. 
Blat presets for aligning same/near genomes are [here](https://github.com/ENCODE-DCC/kentUtils/blob/master/src/hg/utils/automation/doSameSpeciesLiftOver.pl). 
**NOTE:** we strongly advise to test custom parameters to finely tune the analyses. These presets are meant to be used to generate results quickly, and might not be best suited for your purpose.

## Examples of distances among genomes
It can be tricky at times to define how closely or distantly related two genomes are. 
Even though we **strongly** advise to test different parameters and configuration, we hope to help in the decision making by showing some pairs of genomes with their [TreeLife](http://www.timetree.org/) divergence times and their MASH (v2.2) distances.

|       Species 1       |       Species 2       |  TimeTree (MYa) |     MASH     |    Distance    |
|-----------------------|-----------------------|-----------------|--------------|----------------|
| H. sapiens (build 38) | H. sapiens (build 37) |        0        |  0.000144749 |      same      |
| H. sapiens (build 38) |     P. troglodytes    |       6.7       |   0.013239   |  near/primate  |
| H. sapiens (build 38) |      M. musculus      |       90        |   0.210189   | medium/general |
| H. sapiens (build 38) |       G. gallus       |       312       |   1.000000   |       far      |

Again, remember that these are just suggested presets. Each analyses should be considered differently, by testing user-defined sets of parameters.

## Custom parameters
You can apply your own custom parameters to an alignment simply with the `--custom` flag:
```
nextflow run evotools/nf-LO \
   --igenome_source GRCh37 \
   --igenome_target GRCh38 \
   --custom '-cx asm5 -l 10000' \
   --aligner minimap2  
``` 
