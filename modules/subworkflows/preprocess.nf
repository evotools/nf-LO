// Include dependencies
include {make2bit; src2bit; tgt2bit} from "../processes/preprocess" params(params)
include {splitsrc} from "../processes/preprocess" params(params)
include {splittgt} from "../processes/preprocess" params(params)
include {groupsrc} from "../processes/preprocess" params(params)
include {grouptgt} from "../processes/preprocess" params(params)
include {make_mmi as make_mmi_tgt; make_mmi as make_mmi_src} from "../processes/preprocess" params(params)

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
        if ( params.aligner == 'blat' || params.aligner.toLowerCase() == 'gsalign' || params.aligner == 'last' || params.aligner == 'minimap2' ){
            ch_fragm_src_out = splitsrc.out.srcsplit_ch
            ch_fragm_src_fa = splitsrc.out.srcfas_ch.flatten()
        } else {
            splitsrc.out.srcsplit_ch | groupsrc
            ch_fragm_src_out = groupsrc.out.srcclst_ch
            ch_fragm_src_fa = groupsrc.out.srcfas_ch.flatten()
        }

        // split and group target
        splittgt(ch_target)
        tgt_lift = splittgt.out.tgt_lift_ch
        if ( params.aligner.toLowerCase() == 'gsalign'  || (params.aligner == 'minimap2' && params.mm2_full_alignment) ){
            ch_fragm_tgt_out = splittgt.out.tgtsplit_ch
            ch_fragm_tgt_fa = splittgt.out.tgtfas_ch
                .flatten()
                .map{it -> [it.baseName, it]}
        } else {
            splittgt.out.tgtsplit_ch | grouptgt
            ch_fragm_tgt_out = grouptgt.out.tgtclst_ch
            ch_fragm_tgt_fa = grouptgt.out.tgtfas_ch
                .flatten()
                .map{it -> [it.baseName, it]}
        }

        // If minimap2 requested, convert reference to mmi to save memory
        if (params.aligner.toLowerCase() == 'minimap2'){
            ch_fragm_src_fa = ch_fragm_src_fa | make_mmi_src | map{it -> [it.baseName, it]}
        } else {
            ch_fragm_src_fa = ch_fragm_src_fa.map{it -> [it.baseName, it]}
        }

        // Prepare pairs of sequences
        ch_fragm_src_fa
            .combine(ch_fragm_tgt_fa)
            .transpose()
            .set{pairspath_ch}

    emit:
        pairspath_ch
        tgt_lift
        src_lift
        twoBitS
        twoBitT
        twoBitSN
        twoBitTN     
}
