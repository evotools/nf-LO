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
        // Define q-scoring matrix
        if (params.custom && file(params.qscores).exists()) {
            qfile_ch = Channel.fromPath(params.qscores)
        } else if (params.distance == 'near'){
            qfile_ch = params.qscores ? Channel.fromPath(params.qscores) : Channel.fromPath("${projectDir}/assets/human_chimp.v2.q")
        } else if (params.distance == 'medium'){
            qfile_ch = params.qscores ? Channel.fromPath(params.qscores) : Channel.fromPath("${projectDir}/assets/OPTIONAL_FILE")
        } else if (params.distance == 'far') {
            qfile_ch = params.qscores ? Channel.fromPath(params.qscores) : Channel.fromPath("${projectDir}/assets/HoxD55.q")
        } else if (params.distance == 'primate') {
            qfile_ch = params.qscores ? Channel.fromPath(params.qscores) : Channel.fromPath("${projectDir}/assets/human_chimp.v2.q")
        } else if (params.distance == 'general') {
            qfile_ch = params.qscores ? Channel.fromPath(params.qscores) : Channel.fromPath("${projectDir}/assets/general.q")
        } else {
            qfile_ch = Channel.fromPath("${projectDir}/assets/general.q")
            log.info"""Preset ${params.distance} not available for lastz"""
            log.info"""The software will use general instead."""
            log.info"""If it is not ok for you, re-run selecting among the following options:"""
            log.info""" 1 - near"""
            log.info""" 2 - medium"""
            log.info""" 3 - far"""
            log.info""" 4 - primate"""
            log.info""" 5 - general"""
        }
        qfile_ch = qfile_ch | collect


        // Add number of sequences for source fragment
        pairspath_ch = pairspath_ch
            .map{
                srcname, srcfile, tgtname, tgtfile ->
                def nseq = srcfile.countFasta()
                [srcname, srcfile, tgtname, tgtfile, nseq]
            }

        // Run lastz
        lastz(pairspath_ch, tgt_lift, src_lift, qfile_ch)
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
            mafstats( name_maf_seq.out, ch_source.map { it.simpleName }, ch_target.map { it.simpleName }  ) 
            mafs = mafstats.out[0]
            mafc = mafstats.out[1]
            mafi = mafstats.out[2]
        } else {
            mafs = Channel.fromPath("${params.outdir}/stats/placeholder1")
            mafc = Channel.fromPath("${params.outdir}/stats/placeholder2")
            mafi = Channel.fromPath("${params.outdir}/stats/placeholder3")
        }
        
    emit:
        liftover = chainsubset.out.liftover_ch
        net = net_ch
        mafs = mafs
        mafc = mafc
        mafi = mafi
}
