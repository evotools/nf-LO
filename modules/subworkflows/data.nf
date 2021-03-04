include {dataset_genome as dataset_source; dataset_genome as dataset_target; dataset_genome as dataset} from "../processes/datasets" 

workflow DATA {
    main:
        if (!params.source && !params.ncbi_source && !params.igenome_source){
                exit 1, 'Source genome not specified!'
        } else if (!params.source && !params.igenome_source){
                ch_source = dataset_source(params.ncbi_source)
        } else if (!params.source && !params.ncbi_source){
                if (params.igenome_source && params.genomes && !params.genomes.containsKey(params.igenome_source)) {
                        exit 1, "The provided genome '${params.igenome_source}' is not available in the iGenomes file. Currently the available genomes are ${params.genomes.keySet().join(", ")}"
                }
                if (params.igenome_source){ 
                        params.fasta_src = params.igenome_source ? params.genomes[ params.igenome_source ].fasta ?: false : false
                        if (params.fasta_src) { ch_source = file(params.fasta_src, checkIfExists: true) }
                }
        } else if (!params.igenome_source && !params.ncbi_source) {
                ch_source = file(params.source)
        } else {
                exit 1, 'Too many source options provided'
        }


        if (!params.target && !params.ncbi_target && !params.igenome_target){
                exit 1, 'Target genome not specified!'
        } else if (!params.target && !params.igenome_target){
                ch_target = dataset_target(params.ncbi_target)
        } else if (!params.target && !params.ncbi_target){
                if (params.igenome_target && params.genomes && !params.genomes.containsKey(params.igenome_target)) {
                        exit 1, "The provided genome '${params.igenome_target}' is not available in the iGenomes file. Currently the available genomes are ${params.genomes.keySet().join(", ")}"
                }
                if (params.igenome_target){ 
                        params.fasta_tgt = params.igenome_target ? params.genomes[ params.igenome_target ].fasta ?: false : false
                        if (params.fasta_tgt) { ch_target = file(params.fasta_tgt, checkIfExists: true) }
                }
        } else if (!params.ncbi_target && !params.igenome_target) {
                ch_target = file(params.target)
        } else {
                exit 1, 'Too many target options provided'
        }

    emit:
        ch_source
        ch_target
}