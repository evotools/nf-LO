// This subworkflow contains only the workflow to lift input files
include {liftover} from '../processes/postprocess'
workflow LIFTOVER {
    take:
        chain
        ch_annot
    main:
        if (params.liftover_algorithm == 'croosmap' || (params.format != 'bed' && params.format != 'gff') ){
            include {crossmap as liftover} from '../processes/postprocess'
        } else {
            include {liftover} from '../processes/postprocess'
        }
        liftover(chain, ch_annot)
}