# Chain/net generation
The process of chain/netting takes the alignments generated in the previous stage, converts and combines them into a single chain file that is then refined:
1. Alignments to psl: this largely depends on the output type of the aligner, and so there is not a unique tool to do this
2. Generate chain: use axtChain to generate the chain file; the configuration changes depending on the distance of the genomes 
2. Filter out repetitive blocks (ChainAntiRepeat)
3. Remove chains that can't be netted, and creates the net file (chainPreNet/chainNet)
4. Add synteny info to the net file using netSyntenic (optional, can be turned off by `--no_netsynt`)
5. Subset the chain using the net file (chainNetSubset)

## Pre-sets and custom configuration
The software uses several presets for the generation of the chain/net files. 

If you use aligners like lastz and minimap2, it will use netSyntenic to refine the results, whereas using blat and GSAlign won't use it. 

Another important factor is the generation of the chain file through axtChain. The software uses a series of presets, based on the aligner and distance configuration provided:


|       Preset      |   axtChain    |
|-------------------|---------------|
|       near        | -minScore=5000 -linearGap=medium |
|       medium      | -minScore=3000 -linearGap=medium |
|       far         | -minScore=5000 -linearGap=loose |
|      primate      | -minScore=5000 -linearGap=medium |
|      general      | -minScore=3000 -linearGap=medium |
|       balanced    | -minScore=5000 -linearGap=medium    |
|       same        | -minScore=5000 -linearGap=medium |

It is possible to switch off netSyntenic by using the `--no_netsynt` flag. 
Net-syntenic should be used in case of medium-to-distantly related genomes.
It is also possible to specify custom axtChain parameters using the flag `--chainCustom`.
The example below runs the workflow using the GRCh37 and GRCh38 genomes using lastz, with the `near` configuration for the alignments, and a custom
`axtChain` configuration   
```
nextflow run evotools/nf-LO --igenome_source GRCh37 \
   --igenome_target GRCh38 \
   --no_netsynt \
   --chainCustom '-minScore=5000 -linearGap=medium'
```  
