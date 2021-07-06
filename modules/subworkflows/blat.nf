// Include dependencies
include {makeooc} from "../processes/preprocess" params(params)

if (params.custom) {
    include {blat_custom as blat} from '../processes/blat'
} else if (params.distance == 'near'){
    include {blat_near as blat} from '../processes/blat'
} else if (params.distance == 'medium'){
    include {blat_medium as blat} from '../processes/blat'
} else if (params.distance == 'far') {
    include {blat_far as blat} from '../processes/blat'
} else if (params.distance == 'balanced') {
    include {blat_balanced as blat} from '../processes/blat'
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

include {chainMerge; chainNet; netSynt; chainsubset} from "../processes/postprocess"
include {chain2maf; name_maf_seq; mafstats} from "../processes/postprocess"

// Create blat alignments workflow
workflow BLAT {
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
        // Prepare Ooc files
        makeooc(ch_source)

        // Run blat
        blat(pairspath_ch, tgt_lift, src_lift, makeooc.out.ooc11, makeooc.out.ooc12)  
        axtChain( blat.out.al_files_ch, twoBitS, twoBitT)   

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
            mafstats( name_maf_seq.out, ch_source.simpleName, ch_target.simpleName ) 
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
}
