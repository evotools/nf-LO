// Include dependencies
include {makeooc} from "../processes/preprocess" params(params)
if (params.distance == 'near'){
    include {blat_near as blat} from '../processes/blat'
} else if (params.distance == 'medium'){
    include {blat_medium as blat} from '../processes/blat'
} else if (params.distance == 'far') {
    include {blat_far as blat} from '../processes/blat'
} else if (params.distance == 'custom') {
    include {blat_custom as blat} from '../processes/blat'
} else if (params.distance == 'balanced') {
    include {blat_balanced as blat} from '../processes/blat'
}
include {axtchain; chainMerge; chainNet} from "../processes/postprocess"

// Prepare input channels
if (params.source) { ch_source = file(params.source) } else { exit 1, 'Source genome not specified!' }
if (params.target) { ch_target = file(params.target) } else { exit 1, 'Target genome not specified!' }
if (params.annotation) { ch_annot = file(params.annotation) } else { log.info 'No annotation given' }

// Create blat alignments workflow
workflow BLAT {
    take:
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
        axtchain( blat.out.al_files_ch, twoBitS, twoBitT)   

        // 
        chainMerge( axtchain.out.collect() )
        chainNet( chainMerge.out, twoBitS, twoBitT, twoBitSN, twoBitTN )
        
    emit:
        chainNet.out.liftover_ch
        chainNet.out.netfile_ch
}
