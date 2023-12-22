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
| lastz     |       near        | B=0 C=0 E=150 H=0 K=4500 L=3000 M=254 O=600 T=2 Y=15000 Q=human_chimp.v2.q |
|           |       medium      | B=0 C=0 E=30 H=0 K=3000 L=3000 M=50 O=400 T=1 Y=9400  |
|           |       far         | B=0 C=0 E=30 H=2000 K=2200 L=6000 M=50 O=400 T=2 Y=3400 Q=HoxD55.Q |
|           |      primate      | E=30 H=3000 K=5000 L=5000 M=10 O=400 T=1 Q=human_chimp.v2.q |
|           |      general      | E=30 H=3000 K=5000 L=5000 M=10 O=400 T=1 Q=general.q |
| blat      |       near        | -t=dna -q=dna -fastMap -noHead -tileSize=11 -minScore=100 -minIdentity=98 |
|           |       medium      | -t=dna -q=dna -fastMap -noHead -tileSize=11 -stepSize=11 -oneOff=0 -minMatch=2 -minScore=30 -minIdentity=90 -maxGap=2 -maxIntron=75000 |
|           |       far         | -t=dna -q=dna -fastMap -noHead -tileSize=12 -oneOff=1 -minMatch=1 -minScore=30 -minIdentity=80 -maxGap=3 -maxIntron=75000 |
|           |       balanced    | -fastMap -tileSize=12 -minIdentity=98 |
| minimap2  |       near        | -cx asm5 |
|           |       medium      | -cx asm10 |
|           |       far         | -cx asm20 |
| GSAlign   |       near        | -sen -idy 80 |
|           |       medium      | -sen -idy 75 |
|           |       far         | -sen -idy 70 |
|           |       same        | -sen |

In addition, the primate and near configuration use the human_chimp.v2.q scores, the general uses the general.q scores and the distant uses the HoxD55.q, all provided in the `assets` folder. These q-scores can be changed to reflect each use case by providing the `--qscores FILE.q` option, where `FILE.q` is a set of q-scores defined by the user.
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

## Alignment fragmentation and optimization
`nf-LO` speeds up the slow and computationally intensive alignment phase by splitting the alignments into smaller fragments.
The predefined parameters for `nf-LO` are suitable for comparison between small genomes. However, if you are comparing genomes larger than 500Mb it is strongly recommended to tweak the fragmentation to avoid the issue of overwhelming your system with too many alignments files, depending on which aligner you choose to use.
Below the table used in [Talenti A. and Prendergast J., 2022](https://academic.oup.com/gbe/article/13/9/evab183/6349174):

|    Species 1 (src)    |    Species 2 (tgt)    |      Aligner    |   Src size   |   Tgt size   |   Src overlap   |   Tgt overlap   |
|-----------------------|-----------------------|-----------------|--------------|--------------|-----------------|-----------------|
| H. sapiens (build 38) | H. sapiens (build 37) |      blat       | Full genome  | 1Mb (4500bp) |        0        |       500       |
| H. sapiens (build 38) | H. sapiens (build 37) |     GSAlign     | Full genome  | Full genome  |        0        |        0        |
| H. sapiens (build 38) |     P. troglodytes    |      lastz      |  30,000,000  |  10,000,000  |        0        |     100,000     |
| H. sapiens (build 38) |     P. troglodytes    |     minimap2    | Full genome  | Full genome  |        0        |        0        |
| H. sapiens (build 38) |      M. musculus      |      lastz      |  30,000,000  |  10,000,000  |        0        |     100,000     |
| H. sapiens (build 38) |       G. gallus       |      lastz      |  20,000,000  |  10,000,000  |        0        |      50,000     |

These should be seen as examples only, and each case should be considered independently.
Fragmentation of the genomes doesn't apply to `GSAlign` and, with specific settings, [minimap2](#custom-minimap2-options).

You can define the fragmentation of the target genome using:
1. `--tgtSize`: size of the target fragment to consider (in bp)
2. `--tgtOvlp`: overlapping sequence between pairs of fragments from the target genome (in bp)

Analogously, you can define the fragmentation of the source genome using:
1. `--srcSize`: size of the source fragment to consider (in bp)
2. `--srcOvlp`: overlapping sequence between pairs of fragments from the source genome (in bp)

## Custom parameters
You can apply your own custom parameters to an alignment simply with the `--custom` flag:
```
nextflow run evotools/nf-LO \
   --igenome_source GRCh37 \
   --igenome_target GRCh38 \
   --custom '-cx asm5 -l 10000' \
   --aligner minimap2  
``` 

## Custom minimap2 options
Due to its flexible design, we have added some specific configurations for `minimap2` and changed its behaviour as of the recent update.
The default minimap2 behaviour is now to align each sequence from the target genome separately, using one task at the time. This should achieve a good balance of number of processes and low number of cores per process.
If the user wishes to use a single process, as in the previous version of the workflow, they can do so by providing `--mm2_full_alignment`. This will perform a single genome-to-genome process. You might want to increase the number of cores provided to minimap2 with `--minimap2_threads`.
If the user needs to perform the alignment in a particularly low-memory environment, they can provide `--mm2_lowmem`. This will perform the scattering of the target genome using `--tgtSize`, and with the overlap specified in `--tgtOvlp`.
