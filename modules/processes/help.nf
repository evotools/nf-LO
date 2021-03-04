def helpMessage() {
  log.info '''
-------------------------------------
         __           _      ____  
        / _|         | |    / __ \\ 
  _ __ | |_   ______ | |   | |  | |
 | '_ \\|  _| |_____| | |   | |  | |
 | | | | |           | |___| |__| |
 |_| |_|_|           |______\\____/ 
-------------------------------------

      '''
    log.info"""

    Usage:

    The typical command for running the pipeline is as follows:

      nextflow run renzo_tale/nf-LO --source ./data/source.fa --target ./data/target.fa -profile standard

    Source genome (use one of the three options):
      --source [file]                 Path to fa(sta)[.gz] for source genome. (Default: './data/source.fa')
      --ncbi_source [file]            Download source genome using NCBI ID 
      --igenome_source [file]         Download source genome from iGenome

    Target genome (use one of the three options): 
      --target [file]                 Path to fa(sta)[.gz] for target genome. (Default: './data/target.fa')
      --ncbi_target [file]            Download target genome using NCBI ID 
      --igenome_target [file]         Download target genome from iGenome 

    Workflow profile
      -profile [str]                  Configuration profile to use. Can use multiple (comma separated)
                                      Available: standard, conda, docker, singularity, podman, eddie, eddie_conda, sge, uge

    Alignment arguments:
      --distance                        Distance between the two genomes to process. (Default: 'near')
                                        Available: near, medium, far, custom, balanced (blat only), same (GSAlign only),
                                        primate and general (lastz only)
      --aligner                         Algorithm to use to perform the alignment (Default: 'lastz')
                                        Available: lastz, blat, minimap2, gsalign
      --tgtSize                         Size in bp of each chunk to process for the target genome (Default: 10000000)
      --tgtOvlp                         Length of the overlap between consecutive chunks in bp for the target genome (Default: 100000)
      --srcSize                         Size in bp of each chunk to process for the source genome (Default: 20000000)
      --custom                          Use custom parameters for the alignments instead of the pre-defined (Default: false)
                                        Specify the string of custom parameters for the alignments. If want to run with base parameters,
                                        just use ' '
      --customChain                     Use custom parameters for the chaining instead of the pre-defined (Default: false)
                                        Specify the string of custom parameters for the alignments. If want to run with base parameters,
                                        just use ' '
      --netsynt                         Use netSyntenic when chaining different species (Default: true)
    
    Liftover
      --annotation [file]               Path to BED/GFF file to lift. Not mandatory. (Default: false)
      --annotation_format [str]         Path to BED/GFF file to lift. Not mandatory. (Default: false)
                                        Available: bed, gff, wig, bigwig, maf, vcf, bam
                                        Use bam works also with sam and cram, and gff with gtf
      --liftover_algorithm              Define the algorith to use to liftover the positions
                                        Supported software are liftOver and CrossMap.py
      --maf_tgt_name                    Specify the name of the target genome in the maf alignments (for CrossMap only)

    Download genomes
      --igenomes_base                   Root address to iGenome (Default: 's3://ngi-igenomes/igenomes/')
      --igenomes_ignore                 Ignore iGenome configuration (Default: false)  

    Other
      --chain_name [prefix]             Prefix of the output chain file (Default: liftover)
      --no_maf                          Do not save an output maf file (Default: false)
      --outdir [file]                   The output directory where the results will be saved (Default: './results')
      --publish_dir_mode [str]          Mode for publishing results in the output directory. Available: symlink, rellink, link, copy, copyNoFollow, move (Default: copy)"""
}

