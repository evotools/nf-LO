// Include dependencies
include {lastz} from '../processes/lastz'
include {axtChain} from "../processes/postprocess"
include {chainMerge; chainNet; netSynt; chainsubset} from "../processes/postprocess"
include {chain2maf; name_maf_seq; mafstats} from "../processes/postprocess"

// Create lastz alignments workflow
workflow LASTZ {
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
        // Add number of sequences for source fragment
        pairspath_ch = pairspath_ch
            .map{
                srcname, srcfile, tgtname, tgtfile ->
                def nseq = srcfile.countFasta()
                [srcname, srcfile, tgtname, tgtfile, nseq]
            }

        // Run lastz
        lastz(pairspath_ch, tgt_lift, src_lift)  
        axtChain( lastz.out.al_files_ch, twoBitS, twoBitT)   

        // Combine the chain files
        chainMerge( axtChain.out.collect() )
        // Create liftover file from chain
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
        liftover = chainsubset.out.liftover_ch
        net = net_ch
        mafs = mafs
        mafc = mafc
        mafi = mafi
}
