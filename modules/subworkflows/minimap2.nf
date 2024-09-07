// Include dependencies
if (params.custom) {
    include {minimap2_custom as minimap2} from '../processes/minimap2'
} else if (params.distance == 'near'){
    include {minimap2_near as minimap2} from '../processes/minimap2'
} else if (params.distance == 'medium'){
    include {minimap2_medium as minimap2} from '../processes/minimap2'
} else if (params.distance == 'far') {
    include {minimap2_far as minimap2} from '../processes/minimap2'
} else {
    include {minimap2_medium as minimap2} from '../processes/minimap2'
    log.info"""Preset ${params.distance} not available for minimap2"""   
    log.info"""The software will use the medium instead."""   
    log.info"""If it is not ok for you, re-run selecting among the following options:"""   
    log.info""" 1 - near"""   
    log.info""" 2 - medium"""   
    log.info""" 3 - far"""   
}


if (params.distance == 'near' || params.distance == "balanced" || params.distance == "same" || params.distance == "primate"){
    include {axtchain_near as axtChain} from "../processes/postprocess"
} else if (params.distance == 'medium' || params.distance == 'general') {
    include {axtchain_medium as axtChain} from "../processes/postprocess"
} else if (params.distance == 'far') {
    include {axtchain_far as axtChain} from "../processes/postprocess"
} else if (params.chainCustom) {
    include {axtchain_custom as axtChain} from "../processes/postprocess"
}

include {chainMerge; chainNet; netSynt; chainsubset} from "../processes/postprocess"
include {chain2maf; name_maf_seq; mafstats} from "../processes/postprocess"

// Create minimap2 alignments workflow
workflow MINIMAP2 {
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
        // Run minimap2
        minimap2(pairspath_ch, tgt_lift, src_lift)  
        axtChain( minimap2.out.al_files_ch, twoBitS, twoBitT)   

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
        if(!params.no_maf || params.vcf){ 
            chain2maf( chainsubset.out[0], twoBitS, twoBitT, twoBitSN, twoBitTN ) 
            maf = name_maf_seq( chain2maf.out )
            mafstats( maf, ch_source.simpleName, ch_target.simpleName ) 
            mafs = mafstats.out[0]
            mafc = mafstats.out[1]
            mafi = mafstats.out[2]
        } else {
            mafs = file("${params.outdir}/stats/placeholder1")
            mafc = file("${params.outdir}/stats/placeholder2")
            mafi = file("${params.outdir}/stats/placeholder3")
        }
        
    emit:
        chainsubset.out
        net_ch
        mafs
        mafc
        mafi
        maf
}
