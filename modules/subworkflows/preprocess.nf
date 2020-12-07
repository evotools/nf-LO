// Include dependencies
include {make2bit; src2bit; tgt2bit} from "../processes/preprocess" params(params)
include {splitsrc} from "../processes/preprocess" params(params)
include {splittgt} from "../processes/preprocess" params(params)
include {groupsrc} from "../processes/preprocess" params(params)
include {grouptgt} from "../processes/preprocess" params(params)
include {pairs} from "../processes/preprocess" params(params)

// Create minimap2 alignments workflow
workflow PREPROC {
    take:
        ch_source
        ch_target
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
        if ( params.aligner == 'blat' || params.aligner == 'gsalign' || params.aligner == 'last' ){
            ch_fragm_src_out = splitsrc.out.srcsplit_ch
        } else {
            groupsrc(splitsrc.out.srcsplit_ch)
            ch_fragm_src_out = groupsrc.out.srcclst_ch
        }

        // split and group target
        splittgt(ch_target)
        tgt_lift = splittgt.out.tgt_lift_ch
        if ( params.aligner == 'gsalign' ){
            ch_fragm_tgt_out = splittgt.out.tgtsplit_ch
        } else {
            grouptgt(splittgt.out.tgtsplit_ch)
            ch_fragm_tgt_out = grouptgt.out.tgtclst_ch
        }

        // prepare pairs
        pairs( ch_fragm_src_out, ch_fragm_tgt_out )
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
