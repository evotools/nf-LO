// Include dependencies
include {make2bit; src2bit; tgt2bit} from "../processes/preprocess" params(params)
include {splitsrc} from "../processes/preprocess" params(params)
include {splittgt} from "../processes/preprocess" params(params)
include {groupsrc} from "../processes/preprocess" params(params)
include {grouptgt} from "../processes/preprocess" params(params)
include {pairs} from "../processes/preprocess" params(params)

// Prepare input channels
if (params.source) { ch_source = file(params.source) } else { exit 1, 'Source genome not specified!' }
if (params.target) { ch_target = file(params.target) } else { exit 1, 'Target genome not specified!' }

// Create minimap2 alignments workflow
workflow PREPROC {
    main:        
        // Make 2bit genomes
        // make2bit(ch_source, ch_target)
        src2bit(ch_source)
        tgt2bit(ch_target)
        twoBitS = src2bit.out.twoBsrc
        twoBitT = tgt2bit.out.twoBtgt
        twoBitSN = src2bit.out.twoBsrcNFO
        twoBitTN = tgt2bit.out.twoBtgtNFO
        
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

    emit:
        pairspath_ch
        tgt_lift
        src_lift
        twoBitS
        twoBitT
        twoBitSN
        twoBitTN     
}
