# Input files

The software accepts inputs in the common fasta format, uncompressed or compressed with gzip.
Input files can be specified as:
1. Local files
2. Remote links to a web file (e.g. ftp addresses)
3. [iGenomes](https://support.illumina.com/sequencing/sequencing_software/igenome.html) accession
4. [NCBI](https://www.ncbi.nlm.nih.gov/genome/?term=) RefSeq/Genbank accession (GCF or GCA codes)


## Specify a local or remote source/target genome
To specify a local source or target genome, you can use the `--source` and `--target` flags followed by the path to the file:
```
nextflow run evotools/nf-LO --source /PATH/TO/source.fa --target /PATH/TO/target.fa
```
Similarly, you can download a remote file using the same command:
```
nextflow run evotools/nf-LO --source /PATH/TO/source.fa --target ftp://ncbi.nih.nlm.gov/PATH/TO/TARGET/genome.fa.gz
``` 

## Download from iGenomes
Genomes can be downloaded from iGenome simply by using the `--igenome_source`/`igenome_target` followed by the genome code:
```
nextflow run evotools/nf-LO --igenome_source danRer7 --target /PATH/TO/target.fa
```

## Download from NCBI
nf-LO can download the genomes of interest from NCBI simply by using the `--ncbi_source`/`ncbi_target` followed by the genome accession:
```
nextflow run evotools/nf-LO --igenome_source danRer7 --ncbi_target GCA_001899175.1 
```
nf-LO will use the [dataset](https://www.ncbi.nlm.nih.gov/datasets/) software to retrieve the genome of interest and process it

## Conflicts
Remember that you can specify only 1 identifier for the source and 1 identifier for the target. 
If multiple source are provided for the source or the target, the pipeline will stop, not knowing which one to process.
Therefore, remember to use:
1. One among `--source`, `--ncbi_source` or `--igenome_source`
2. One among `--target`, `--ncbi_target` or `--igenome_target`
