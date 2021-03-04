// Include dependencies
if (params.distance == 'near'){
    include {lastz_near as lastz} from '../processes/lastz'
} else if (params.distance == 'medium'){
    include {lastz_medium as lastz} from '../processes/lastz'
} else if (params.distance == 'far') {
    include {lastz_far as lastz} from '../processes/lastz'
} else if (params.distance == 'primate' || params.distance == 'primates') {
    include {lastz_primates as lastz} from '../processes/lastz'
}else if (params.distance == 'general') {
    include {lastz_general as lastz} from '../processes/lastz'
}else if (params.distance == 'custom') {
    include {lastz_custom as lastz} from '../processes/lastz'
}

//include {lastz_near; lastz_medium; lastz_far; lastz_custom} from "../processes/lastz"
include {axtchain; chainMerge; chainNet; liftover; chain2maf} from "../processes/postprocess"

// Create lastz alignments workflow
workflow LASTZ {
    take:
        pairspath_ch
        tgt_lift
        src_lift
        twoBitS
        twoBitT
        twoBitSN
        twoBitTN  

    main:
        // Run lastz
        lastz(pairspath_ch, tgt_lift, src_lift)  
        axtchain( lastz.out.al_files_ch, twoBitS, twoBitT)   

        // Combine the chain files
        chainMerge( axtchain.out.collect() )
        // Create liftover file from chain
        chainNet( chainMerge.out, twoBitS, twoBitT, twoBitSN, twoBitTN )
        chain2maf( chainNet.out[0], twoBitS, twoBitT, twoBitSN, twoBitTN )

    emit:
        chainNet.out.liftover_ch
        chainNet.out.netfile_ch
}
