include {dataset_genome as dataset_source; dataset_genome as dataset_target; dataset_genome as dataset} from "../processes/datasets" 

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
                        if (params.fasta_src) { ch_source = file(params.fasta_src, checkIfExists: true) }
                }
        } else if (!params.igenomes_source && !params.ncbi_source) {
                ch_source = file(params.source)
        } else {                
                log.info"Too many source options provided"
                exit 1, 'Too many source options provided'
        }


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