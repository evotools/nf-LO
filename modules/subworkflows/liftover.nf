// This subworkflow contains only the workflow to lift input files
include {crossmap; liftover} from '../processes/postprocess'
include { features_stats } from '../processes/postprocess'

workflow LIFTOVER {
    take:
        chain
        ch_annot
        ch_tgt
    main:   
        if (params.annotation != 'bed'){ 
            log.info "Using CrossMap"
            lifted = crossmap(chain, ch_annot, ch_tgt)
        } else {
            log.info "Using ${params.liftover_algorithm}" 
            if (params.liftover_algorithm == 'crossmap'){
                lifted = crossmap(chain, ch_annot, ch_tgt)
            } else {
                lifted = liftover(chain, ch_annot)
            }
        }
        features_stats( ch_annot, lifted.lifted_ch )
    emit:
        features_stats.out
}