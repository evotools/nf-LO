# Step-by-step example
*nf-LO* is a workflow that generates chain/net files for any two pairs of genomes. 
These genomes can be either local or remote (the latter provided as an ftp address, iGenome ID or RefSeq/GenBank accession from NCBI).

## Installation
First, check you have all you need to run *nf-LO*. If you're in a hurry, just install nextflow and anaconda: you're ready to go! 
If you need more control, or you can't run anaconda, follow the [installation](https://github.com/evotools/nf-LO/wiki/Installation) section to find the best solution for you.

## Premise
Before running nextflow, you have to decide what type of workflow you want to use. This depends on whether you are processing genomes of the same species, or of different species, and how closely related they are.
The choice is ultimately yours; in general, we recommend the following:
 - same species liftover: blat and GSAlign
 - different species liftover: lastz and minimap2

We also provide a series of pre-defined configurations. These are described in the [alignments](https://github.com/evotools/nf-LO/wiki/Alignments) and [chaining](https://github.com/evotools/nf-LO/wiki/Chain-Netting) pages of the wiki. 
  
## Run the workflow
Once defined the type of aligner you want to use and the distance among your genomes, you can simply run *nf-LO* as follow:

```
nextflow run evotools/nf-LO --source mygenome1.fa --target mygenome2.fa --distance near --aligner lastz --outdir ./liftover_genome1_genome2 --no_netsynt -profile conda 
```

The workflow will pre-process the inputs and return the results in the folder specified. The content is better described in the [output](https://github.com/evotools/nf-LO/wiki/Outputs) section.