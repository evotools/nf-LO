// Include dependencies
 if (params.custom) {
    include {gsalign_custom as gsalign} from '../processes/GSAlign'
} else if (params.distance == 'near'){
    include {gsalign_near as gsalign} from '../processes/GSAlign'
} else if (params.distance == 'medium'){
    include {gsalign_medium as gsalign} from '../processes/GSAlign'
} else if (params.distance == 'far') {
    include {gsalign_far as gsalign} from '../processes/GSAlign'
} else if (params.distance == 'same') {
    include {gsalign_same as gsalign} from '../processes/GSAlign'
}


if (params.chainCustom) {
    include {axtchain_custom as axtChain} from "../processes/postprocess"
} else if (params.distance == 'near' || params.distance == "balanced" || params.distance == "same" || params.distance == "primate"){
    include {axtchain_near as axtChain} from "../processes/postprocess"
} else if (params.distance == 'medium' || params.distance == 'general') {
    include {axtchain_medium as axtChain} from "../processes/postprocess"
} else if (params.distance == 'far') {
    include {axtchain_far as axtChain} from "../processes/postprocess"
}

include {bwt_index} from '../processes/GSAlign'
include {chainMerge; chainNet; netSynt; chainsubset} from "../processes/postprocess"
include {chain2maf; name_maf_seq; mafstats} from "../processes/postprocess"
// Create gsalign alignments workflow
workflow GSALIGN {
    take:
        ch_source 
        ch_target
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
        axtChain( gsalign.out.al_files_ch, twoBitS, twoBitT)   

        // 
        chainMerge( axtChain.out.collect() )
        chainNet( chainMerge.out, twoBitS, twoBitT, twoBitSN, twoBitTN )
        if (params.no_netsynt){
            net_ch = chainNet.out
        } else {
            netSynt(chainNet.out)
            net_ch = netSynt.out
        }
        chainsubset(net_ch, chainMerge.out)
        if(!params.no_maf){ 
            chain2maf( chainsubset.out[0], twoBitS, twoBitT, twoBitSN, twoBitTN ) 
            name_maf_seq( chain2maf.out )
            if (params.mafTools || workflow.containerEngine ){
                mafstats( name_maf_seq.out, ch_source.simpleName, ch_target.simpleName ) 
            }
        }
        
    emit:
        chainsubset.out
        net_ch
}
