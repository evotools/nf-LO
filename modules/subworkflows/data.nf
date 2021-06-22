include {dataset_genome as dataset_source; dataset_genome as dataset_target; dataset_genome as dataset} from "../processes/datasets" 

workflow DATA {
    main:
        if (!params.source && !params.ncbi_source && !params.igenomes_source){
                exit 1, 'Source genome not specified!'
        } else if (!params.source && !params.igenomes_source){
                ch_source = dataset_source(params.ncbi_source)
        } else if (!params.source && !params.ncbi_source){
                if (params.igenomes_source && params.genomes && !params.genomes.containsKey(params.igenomes_source)) {
                        exit 1, "The provided genome '${params.igenomes_source}' is not available in the iGenomes file. Currently the available genomes are ${params.genomes.keySet().join(", ")}"
                }
                if (params.igenomes_source){ 
                        params.fasta_src = params.igenomes_source ? params.genomes[ params.igenomes_source ].fasta ?: false : false
                        if (params.fasta_src) { ch_source = file(params.fasta_src, checkIfExists: true) }
                }
        } else if (!params.igenomes_source && !params.ncbi_source) {
                ch_source = file(params.source)
        } else {                
                log.info"Too many source options provided"
                exit 1, 'Too many source options provided'
        }


        if (!params.target && !params.ncbi_target && !params.igenomes_target){
                exit 1, 'Target genome not specified!'
        } else if (!params.target && !params.igenomes_target){
                ch_target = dataset_target(params.ncbi_target)
        } else if (!params.target && !params.ncbi_target){
                if (params.igenomes_target && params.genomes && !params.genomes.containsKey(params.igenomes_target)) {
                        exit 1, "The provided genome '${params.igenomes_target}' is not available in the iGenomes file. Currently the available genomes are ${params.genomes.keySet().join(", ")}"
                }
                if (params.igenomes_target){ 
                        params.fasta_tgt = params.igenomes_target ? params.genomes[ params.igenomes_target ].fasta ?: false : false
                        if (params.fasta_tgt) { ch_target = file(params.fasta_tgt, checkIfExists: true) }
                }
        } else if (!params.ncbi_target && !params.igenomes_target) {
                ch_target = file(params.target)
        } else {
                log.info"Too many target options provided"
                exit 1, 'Too many target options provided'
        }

    emit:
        ch_source
        ch_target
}