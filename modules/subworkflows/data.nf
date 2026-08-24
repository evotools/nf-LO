include {dataset_genome as dataset_source; dataset_genome as dataset_target; dataset_genome as dataset} from "../processes/datasets" 
include {decompress as decompress_src} from "../processes/preprocess"
include {decompress as decompress_tgt} from "../processes/preprocess"

workflow DATA {
    main:
        if (!params.source){
                exit 1, 'Source genome not specified!'
        } else if (params.igenomes_source && params.ncbi_source){
                exit 1, 'Choose only one between --ncbi_target and --igenomes_target'
        } else if (params.source && params.ncbi_source){
                ch_source = dataset_source(params.source)
        } else if (params.source && params.igenomes_source){
                if (params.igenomes_source && params.genomes && !params.genomes.containsKey(params.source)) {
                        exit 1, "The provided genome '${params.source}' is not available in the iGenomes file. Currently the available genomes are ${params.genomes.keySet().join(", ")}"
                }
                else { 
                        params.fasta_src = params.source ? params.genomes[ params.source ].fasta ?: false : false
                        if (params.fasta_src) { ch_source = Channel.fromPath(params.fasta_src, checkIfExists: true) }
                }
        } else if (!params.igenomes_source && !params.ncbi_source) {
                ch_source = Channel.fromPath(params.source, checkIfExists: true)
        } else {                
                log.info"Too many source options provided"
                exit 1, 'Too many source options provided'
        }
        // Autodecompress the fasta files if necessary
        ch_src_branched = ch_source
        .branch {
                compressed: it.name.endsWith('.gz') | it.name.endsWith('.bgz')
                plain: true
        }
        ch_src_decompressed = decompress_src(ch_src_branched.compressed)
        ch_source = ch_src_branched.plain.mix(ch_src_decompressed)

        // Process the target genome
        if (!params.target){
                exit 1, 'Target genome not specified!'
        } else if (params.igenomes_target && params.ncbi_target){
                exit 1, 'Choose only one between --ncbi_target and --igenomes_target'
        } else if (params.target && params.ncbi_target){
                ch_target = dataset_target(params.target)
        } else if (params.target && params.igenomes_target){
                if (params.igenomes_target && params.genomes && !params.genomes.containsKey(params.target)) {
                        exit 1, "The provided genome '${params.target}' is not available in the iGenomes file. Currently the available genomes are ${params.genomes.keySet().join(", ")}"
                }
                else { 
                        params.fasta_tgt = params.target ? params.genomes[ params.target ].fasta ?: false : false
                        if (params.fasta_tgt) { ch_target = Channel.fromPath(params.fasta_tgt, checkIfExists: true) }
                }
        } else if (!params.ncbi_target && !params.igenomes_target) {
                ch_target = Channel.fromPath(params.target, checkIfExists: true)
        } else {
                log.info"Too many target options provided"
                exit 1, 'Too many target options provided'
        }
        // Autodecompress the fasta files if necessary
        ch_tgt_branched = ch_target
        .branch {
                compressed: it.name.endsWith('.gz') | it.name.endsWith('.bgz')
                plain: true
        }
        ch_tgt_decompressed = decompress_tgt(ch_tgt_branched.compressed)
        ch_target = ch_tgt_branched.plain.mix(ch_tgt_decompressed)

    emit:
        ch_source
        ch_target
}