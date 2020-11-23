// This subworkflow contains only the workflow to lift input files
if (params.liftover_algorithm == 'crossmap' || (params.annotation_format != 'bed' && params.annotation_format != 'gff') ){
    include {crossmap as lifter} from '../processes/postprocess'
} else {
    include {liftover as lifter} from '../processes/postprocess'
}
workflow LIFTOVER {
    take:
        chain
        ch_annot
    main:   
        lifter(chain, ch_annot)
}