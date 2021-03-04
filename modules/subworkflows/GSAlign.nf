// Include dependencies
if (params.distance == 'near'){
    include {gsalign_near as gsalign} from '../processes/GSAlign'
} else if (params.distance == 'medium'){
    include {gsalign_medium as gsalign} from '../processes/GSAlign'
} else if (params.distance == 'far') {
    include {gsalign_far as gsalign} from '../processes/GSAlign'
} else if (params.distance == 'custom') {
    include {gsalign_custom as gsalign} from '../processes/GSAlign'
} else if (params.distance == 'same') {
    include {gsalign_same as gsalign} from '../processes/GSAlign'
}
include {bwt_index} from '../processes/GSAlign'
include {axtchain; chainMerge; chainNet; chain2maf} from "../processes/postprocess"

// Create gsalign alignments workflow
workflow GSALIGN {
    take:
        pairspath_ch
        tgt_lift
        src_lift
        twoBitS
        twoBitT
        twoBitSN
        twoBitTN  

    main:
        // make index
        bwt_index( pairspath_ch.groupTuple(by: [0, 1] ).unique() )

        // Run gsalign
        gsalign( pairspath_ch, tgt_lift, src_lift, bwt_index.out.collect() )  
        axtchain( gsalign.out.al_files_ch, twoBitS, twoBitT)   

        // 
        chainMerge( axtchain.out.collect() )
        chainNet( chainMerge.out, twoBitS, twoBitT, twoBitSN, twoBitTN )
        if(!params.no_maf){ chain2maf( chainNet.out[0], twoBitS, twoBitT, twoBitSN, twoBitTN ) }
        
    emit:
        chainNet.out.liftover_ch
        chainNet.out.netfile_ch
}
