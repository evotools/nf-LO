def helpMessage() {
  log.info '''
------------------------------------
        __           _      ____  
       / _|         | |    / __ \\ 
 _ __ | |_   ______ | |   | |  | |
| '_ \\|  _| |_____| | |   | |  | |
| | | | |           | |___| |__| |
|_| |_|_|           |______\\____/ 
------------------------------------

      '''
    log.info"""

    Usage:

    The typical command for running the pipeline is as follows:

      nextflow run renzo_tale/nf-LO --source ./data/source.fa --target ./data/target.fa -profile standard

    Mandatory arguments:
      --source [file]                 Path to fa(sta)[.gz] for source genome. (Default: './data/source.fa')
      --target [file]                 Path to fa(sta)[.gz] for target genome. (Default: './data/target.fa')
      --annotation [file]             Path to BED/GFF file to lift. Not mandatory. (Default: false)
      --annotation_format [str]       Path to BED/GFF file to lift. Not mandatory. (Default: false)
                                      Available: bed, gff, wig, bigwig, maf, vcf, bam
                                      Use bam works also with sam and cram, and gff with gtf
      -profile [str]                  Configuration profile to use. Can use multiple (comma separated)
                                      Available: standard, conda, docker, singularity, eddie, sge, uge

    Alignment arguments:
    --distance                        Distance between the two genomes to process. (Default: 'near')
                                      Available: near, medium, far, custom, balanced (blat) and same (GSAlign)
    --aligner                         Algorithm to use to perform the alignment (Default: 'lastz')
                                      Available: lastz, blat, last, minimap2, gsalign
    --tgtSize                         Size in bp of each chunk to process for the target genome (Default: 10000000)
    --tgtOvlp                         Length of the overlap between consecutive chunks in bp for the target genome (Default: 100000)
    --srcSize                         Size in bp of each chunk to process for the source genome (Default: 20000000)
    --custom                          Use custom parameters for the alignments instead of the pre-defined (Default: false)
                                      Specify the string of custom parameters for the alignments. If want to run with base parameters,
                                      just use ' '
    --customChain                     Use custom parameters for the chaining instead of the pre-defined (Default: false)
                                      Specify the string of custom parameters for the alignments. If want to run with base parameters,
                                      just use ' '
    
    Liftover
    --liftover_algorithm              Define the algorith to use to liftover the positions
                                      Supported software are liftOver and CrossMap.py
    --maf_tgt_name                    Specify the name of the target genome in the maf alignments (for CrossMap only)

    Other
      --outdir [file]                 The output directory where the results will be saved (Default: './results')
      --publish_dir_mode [str]        Mode for publishing results in the output directory. Available: symlink, rellink, link, copy, copyNoFollow, move (Default: copy)"""
}

