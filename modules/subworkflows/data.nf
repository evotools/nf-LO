include {dataset_genome as dataset_source; dataset_genome as dataset_target} from "../processes/datasets" 

workflow DATA {
    main:
        if (params.ncbi_source || params.ncbi_target){
                if (params.ncbi_source){ ch_source = dataset_source(params.source) }
                if (params.ncbi_target){ ch_target = dataset_target(params.target) }
        } else if (params.igenome_source || params.igenome_target){
                if (params.igenome_source && params.genomes && params.source && !params.genomes.containsKey(params.source)) {
                        exit 1, "The provided genome '${params.source}' is not available in the iGenomes file. Currently the available genomes are ${params.genomes.keySet().join(", ")}"
                }
                if (params.igenome_target && params.genomes && params.source && !params.genomes.containsKey(params.target)) {
                        exit 1, "The provided genome '${params.target}' is not available in the iGenomes file. Currently the available genomes are ${params.genomes.keySet().join(", ")}"
                }

                if (params.igenome_source){ 
                        params.fasta_src = params.source ? params.genomes[ params.source ].fasta ?: false : false
                        if (params.fasta_src) { ch_source = file(params.fasta_src, checkIfExists: true) }
                }
                if (params.igenome_target){ 
                        params.fasta_tgt = params.target ? params.genomes[ params.target ].fasta ?: false : false
                        if (params.fasta_tgt) { ch_target = file(params.fasta_tgt, checkIfExists: true) }
                }
        } else {
                if (params.source) { ch_source = file(params.source) } else { exit 1, 'Source genome not specified!' }
                if (params.target) { ch_target = file(params.target) } else { exit 1, 'Target genome not specified!' }
        }
    emit:
        ch_source
        ch_target
}