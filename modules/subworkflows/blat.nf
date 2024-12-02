// Include dependencies
include {makeooc} from "../processes/preprocess"
include {blat} from '../processes/blat'
include {axtChain} from "../processes/postprocess"
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
        // Check that preset is among the available ones


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
            chain2maf( chainsubset.out.liftover_ch, twoBitS, twoBitT, twoBitSN, twoBitTN ) 
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
        liftover = chainsubset.out.liftover_ch
        net = net_ch
        mafs = mafs
        mafc = mafc
        mafi = mafi
}
