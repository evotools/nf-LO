include {dataset_genome as dataset_source; dataset_genome as dataset_target} from "../processes/datasets" 

workflow DATA {
    main:
        if (params.ncbi_source || params.ncbi_target){
                if (params.ncbi_source){ ch_source = dataset_source(params.source, get_dataset.out) }
                if (params.ncbi_target){ ch_target = dataset_target(params.target, get_dataset.out) }
        } else {
                if (params.source) { ch_source = file(params.source) } else { exit 1, 'Source genome not specified!' }
                if (params.target) { ch_target = file(params.target) } else { exit 1, 'Target genome not specified!' }
        }
    emit:
        ch_source
        ch_target
}