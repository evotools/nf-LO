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
include { features_stats } from '../processes/postprocess'
workflow LIFTOVER {
    take:
        chain
        ch_annot
        ch_tgt
    main:   
        lifter(chain, ch_annot, ch_tgt)
        features_stats( ch_annot, lifter.out.lifted_ch )
}