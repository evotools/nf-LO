// Include dependencies
if (params.custom) {
    include {lastz_custom as lastz} from '../processes/lastz'
} else if (params.distance == 'near'){
    include {lastz_near as lastz} from '../processes/lastz'
} else if (params.distance == 'medium'){
    include {lastz_medium as lastz} from '../processes/lastz'
} else if (params.distance == 'far') {
    include {lastz_far as lastz} from '../processes/lastz'
} else if (params.distance == 'primate') {
    include {lastz_primates as lastz} from '../processes/lastz'
} else if (params.distance == 'general') {
    include {lastz_general as lastz} from '../processes/lastz'
} else if (params.custom){
    include {lastz_custom as lastz} from '../processes/lastz'
} else {
    include {lastz_general as lastz} from '../processes/lastz'
    log.info"""Preset ${params.distance} not available for lastz"""   
    log.info"""The software will use general instead."""   
    log.info"""If it is not ok for you, re-run selecting among the following options:"""   
    log.info""" 1 - near"""   
    log.info""" 2 - medium"""   
    log.info""" 3 - far"""   
    log.info""" 4 - primate"""   
    log.info""" 5 - general"""   
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

//include {lastz_near; lastz_medium; lastz_far; lastz_custom} from "../processes/lastz"
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
        pairspath_ch
            .map{
                srcname, srcfile, tgtname, tgtfile ->
                def nseq = srcfile.countFasta()
                [srcname, srcfile, tgtname, tgtfile, nseq]
            }
            .set{pairspath_ch}

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
        chainsubset.out
        net_ch
        mafs
        mafc
        mafi
}
