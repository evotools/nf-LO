// Include dependencies
include {make2bit} from "../processes/preprocess" params(params)
include {splitsrc} from "../processes/preprocess" params(params)
include {splittgt} from "../processes/preprocess" params(params)
include {groupsrc} from "../processes/preprocess" params(params)
include {grouptgt} from "../processes/preprocess" params(params)
include {makeooc} from "../processes/preprocess" params(params)
include {pairs} from "../processes/preprocess" params(params)
if (params.distance == 'near'){
    include {gsalign_near as gsalign} from '../processes/GSAlign'
} else if (params.distance == 'medium'){
    include {gsalign_medium as gsalign} from '../processes/GSAlign'
} else if (params.distance == 'far') {
    include {gsalign_far as gsalign} from '../processes/GSAlign'
} else if (params.distance == 'custom') {
    include {gsalign_custom as gsalign} from '../processes/GSAlign'
} else if (params.distance == 'same') {
    include {gsalign_balanced as gsalign} from '../processes/GSAlign'
}
include {axtchain; chainMerge; chainNet} from "../processes/postprocess"

// Prepare input channels
if (params.source) { ch_source = file(params.source) } else { exit 1, 'Source genome not specified!' }
if (params.target) { ch_target = file(params.target) } else { exit 1, 'Target genome not specified!' }
if (params.annotation) { ch_annot = file(params.annotation) } else { log.info 'No annotation given' }

// Create gsalign alignments workflow
workflow GSALIGN {
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

        // Run gsalign
        gsalign(pairspath_ch, tgt_lift, src_lift)  
        axtchain( gsalign.out.al_files_ch, twoBitS, twoBitT)   

        // 
        chainMerge( axtchain.out.collect() )
        chainNet( chainMerge.out, twoBitS, twoBitT, twoBitSN, twoBitTN )

    emit:
        chainNet.out.liftover_ch
        chainNet.out.netfile_ch
}
