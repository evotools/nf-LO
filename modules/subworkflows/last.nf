// Include dependencies
include {make2bit} from "../processes/preprocess" params(params)
include {splitsrc} from "../processes/preprocess" params(params)
include {splittgt} from "../processes/preprocess" params(params)
include {groupsrc} from "../processes/preprocess" params(params)
include {grouptgt} from "../processes/preprocess" params(params)
include {makeooc} from "../processes/preprocess" params(params)
include {pairs} from "../processes/preprocess" params(params)
if (params.distance == 'near'){
    include {last_near as last} from '../processes/last'
} else if (params.distance == 'medium'){
    include {last_medium as last} from '../processes/last'
} else if (params.distance == 'far') {
    include {last_far as last} from '../processes/last'
} else if (params.distance == 'custom') {
    include {last_custom as last} from '../processes/last'
}
include {axtchain; chainMerge; chainNet; liftover} from "../processes/postprocess"

// Prepare input channels
if (params.source) { ch_source = file(params.source) } else { exit 1, 'Source genome not specified!' }
if (params.target) { ch_target = file(params.target) } else { exit 1, 'Target genome not specified!' }
if (params.annotation) { ch_annot = file(params.annotation) } else { log.info 'No annotation given' }

// Create last alignments workflow
workflow LAST {
    main:
        // Make 2bit genomes
        make2bit(ch_source, ch_target)
        twoBitS = make2bit.out.twoBsrc
        twoBitT = make2bit.out.twoBtgt
        twoBitSN = make2bit.out.twoBsrcNFO
        twoBitTN = make2bit.out.twoBtgtNFO
        
        // split and group source
        splitsrc(ch_source)
        src_lift = splitsrc.out.src_lift_ch
        groupsrc(splitsrc.out.srcsplit_ch)

        // split and group target
        splittgt(ch_target)
        tgt_lift = splittgt.out.tgt_lift_ch
        grouptgt(splittgt.out.tgtsplit_ch)

        // prepare pairs
        pairs(groupsrc.out.srcclst_ch, grouptgt.out.tgtclst_ch)
        pairs.out.pairspath
            .splitCsv(header: ['srcname', 'srcfile', 'tgtname', 'tgtfile'])
            .map{ row-> tuple(row.srcname, row.srcfile, row.tgtname, row.tgtfile) }
            .set{ pairspath_ch }

        // Run last
        last(pairspath_ch, tgt_lift, src_lift)  
        axtchain( last.out.al_files_ch, twoBitS, twoBitT)   

        // Combine the chain files
        chainMerge( axtchain.out.collect() )
        // Create liftover file from chain
        chainNet( chainMerge.out, twoBitS, twoBitT, twoBitSN, twoBitTN )

    emit:
        chainNet.out.liftover_ch
        chainNet.out.netfile_ch
}
