// Include dependencies
if (params.distance == 'near'){
    include {last_near as last} from '../processes/last'
} else if (params.distance == 'medium'){
    include {last_medium as last} from '../processes/last'
} else if (params.distance == 'far') {
    include {last_far as last} from '../processes/last'
} else if (params.distance == 'custom') {
    include {last_custom as last} from '../processes/last'
}
include { make_db; last_train } from '../processes/last'
include {axtchain; chainMerge; chainNet; liftover} from "../processes/postprocess"

// Prepare input channels
if (params.source) { ch_source = file(params.source) } else { exit 1, 'Source genome not specified!' }
if (params.target) { ch_target = file(params.target) } else { exit 1, 'Target genome not specified!' }
if (params.annotation) { ch_annot = file(params.annotation) } else { log.info 'No annotation given' }

// Create last alignments workflow
workflow LAST {
    take:
        pairspath_ch
        tgt_lift
        src_lift
        twoBitS
        twoBitT
        twoBitSN
        twoBitTN  

    main:
        // Make DB
        make_db( pairspath_ch.groupTuple(by: [0, 1] ).unique() )

        // Train model
        last_train( make_db.out.collect(), ch_target )

        // Run last
        last( pairspath_ch, tgt_lift, src_lift, twoBitS, twoBitT, make_db.out.collect(), last_train.out )  

        // Combine the chain files
        chainMerge( last.out.collect() )
        // Create liftover file from chain
        chainNet( chainMerge.out, twoBitS, twoBitT, twoBitSN, twoBitTN )

    emit:
        chainNet.out.liftover_ch
        chainNet.out.netfile_ch
}
