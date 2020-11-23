// This subworkflow contains only the workflow to lift input files
include {liftover} from '../processes/postprocess'
workflow LIFTOVER {
    take:
        chain
        ch_annot
    main:
        liftover(chain, ch_annot)
}