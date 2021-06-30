# Lifting over my positions

This stage is optional, and will be performed only if an input file is specified with `--annotation`, together with its file type using `--annotation_format`:
```
nextflow run evotools/nf-LO --source GRCh37 --target GRCh38 --aligner minimap2 --distance near --annotation s3://ngi-igenomes/igenomes/Homo_sapiens/Ensembl/GRCh37/Annotation/Genes/genes.gtf --annotation_type gff
```

## Algorithms
The lift over can be performed in two different ways:
1. Using the UCSC liftOver algorithm (`--liftover_algorithm 'liftover'`)
2. Using the crossmap software (`--liftover_algorithm 'crossmap'`)

Keep in mind that, if the file type is different from bed and gff, crossmap will be used by default since liftOver cannot accept these files:
| File type |   Software used   | 
|-----------|-------------------|
|  gtf/gff  | liftOver/crossmap |
|    bed    | liftOver/crossmap |
|    vcf    |      crossmap     |
|    bam    |      crossmap     |
|    maf    |      crossmap     |