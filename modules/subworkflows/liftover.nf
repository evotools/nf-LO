// This subworkflow contains only the workflow to lift input files
if (params.annotation != 'bed'){ 
    log.info "Using CrossMap" 
    include {crossmap as lifter} from '../processes/postprocess'
} else {
    log.info "Using ${params.liftover_algorithm}" 
    if (params.liftover_algorithm == 'crossmap'){
        include {crossmap as lifter} from '../processes/postprocess'
    } else {
        include {liftover as lifter} from '../processes/postprocess'
    }
}

workflow LIFTOVER {
    take:
        chain
        ch_annot
    main:   
        lifter(chain, ch_annot)
}