#!/usr/bin/env nextflow
nextflow.enable.dsl=2

/*
 * Perform liftover from source to target using lastz (different species) 
 * or blat (same species).
 * Specify alignments options in the field alignerparam.
 * Outputs will be saved in the folder specified in outdir.
 * If an annotation is provided as bed/gff, liftover will lift it. 
 * If no annotation is provided, set to 'NO_FILE' or ''
 * Karyotype can be specified as ranges (e.g. 1-22), single different 
 * chromosomes can be added after comma (e.g. 1-22,X,Y,Mt).
 */
// Include all stuff
include {helpMessage} from './modules/processes/help.nf'
include {LASTZ} from './modules/subworkflows/lastz'
include {BLAT} from './modules/subworkflows/blat'
include {MINIMAP2} from './modules/subworkflows/minimap2'
include {GSALIGN} from './modules/subworkflows/GSAlign'
include {PREPROC} from './modules/subworkflows/preprocess'
include {LIFTOVER} from './modules/subworkflows/liftover'
include {DATA} from './modules/subworkflows/data'
include {make_report} from './modules/processes/postprocess'

// Run the workflow
workflow {
        if (params.help) {
                helpMessage()
                exit 0
        }

        // If params.custom is set, define that as distance
        if ( params.custom != '' && params.distance == 'custom' ) { params.distance = 'custom' }

        // If params.custom is set, define that as distance
        if ( !params.source && !params.target ) { log.error "You did not provide a source and a target files."; exit 1 }
        if ( !params.source && params.target ) { log.error "You did not provide a source file."; exit 1 }
        if ( params.source && !params.target ) { log.error "You did not provide a target file."; exit 1 }
        if ( params.mm2_full_alignment && params.mm2_lowmem ) { log.error "Incompatible options: --mm2_lowmem and --mm2_full_alignment."; exit 1 }

        // Print run informations
        log.info '''
======================================
        __           _      ____  
        / _|         | |    / __ \\ 
_ __ | |_   ______ | |   | |  | |
| '_ \\|  _| |_____| | |   | |  | |
| | | | |           | |___| |__| |
|_| |_|_|           |______\\____/ 
======================================'''
        log.info """\
Nextflow LiftOver v ${workflow.manifest.version}
======================================"""
        if (params.ncbi_source){
                log.info"""source          : $params.source (NCBI)"""
        } else if (params.igenomes_source) {
                log.info"""source          : $params.source (iGenome)"""
        } else {
                log.info"""source          : $params.source"""
        }
        if (params.ncbi_target){
                log.info"""target          : $params.target (NCBI)"""
        } else if (params.igenomes_target) {
                log.info"""target          : $params.target (iGenome)"""
        } else {
                log.info"""target          : $params.target"""
        }
        log.info"""aligner         : $params.aligner
distance        : $params.distance
custom align    : $params.custom
custom chain    : $params.chainCustom
source chunk    : $params.srcSize
source overlap  : $params.srcOvlp
target chunk    : $params.tgtSize
target overlap  : $params.tgtOvlp
output folder   : $params.outdir
liftover name   : $params.chain_name
annot           : $params.annotation
annot type      : $params.annotation_format
liftover meth.  : $params.liftover_algorithm
igenomes_base   : $params.igenomes_base
igenomes_ignore : $params.igenomes_ignore
report          : $params.report
mamba           : $params.mamba
no_maf          : $params.no_maf"""
        if (params.qscores){
                log.info"""q-scores        : $params.qscores"""
        } 
        log.info"""skip netsynt    : $params.no_netsynt""" 
        if (params.minimap2_threads && params.aligner == 'minimap2'){
                log.info"""low memory (mm2): $params.minimap2_threads"""
        } 
        if (params.gsalign_threads && params.aligner == 'gsalign'){
                log.info"""low memory (mm2): $params.gsalign_threads"""
        } 
        if (params.mm2_lowmem){
                log.info"""low memory (mm2): $params.mm2_lowmem"""
        } 
        if (params.mm2_full_alignment){
                log.info"""full-alignment  : $params.mm2_full_alignment"""
        } 
        if (params.mafTools){
                log.info"""mafTools        : $params.mafTools"""
        } 
        if (params.max_cpus){
                log.info"""max cpus        : $params.max_cpus"""
        } 
        if (params.max_memory){
                log.info"""max memory      : $params.max_memory"""
        } 
        if (params.max_time){
                log.info"""max run time    : $params.max_time"""
        } 
        if (workflow.containerEngine){
                log.info """container       : $workflow.containerEngine"""
        }

        DATA()
        ch_source = DATA.out.ch_source
        ch_target = DATA.out.ch_target
        preproc_ch = PREPROC( ch_source, ch_target )
        if ( params.aligner == 'lastz' ){
                aligned_ch = LASTZ(
                        ch_source,
                        ch_target,
                        preproc_ch.pairspath_ch,
                        preproc_ch.tgt_lift,
                        preproc_ch.src_lift,
                        preproc_ch.twoBitS,
                        preproc_ch.twoBitT,
                        preproc_ch.twoBitSN,
                        preproc_ch.twoBitTN
                )
        } else if ( params.aligner == 'blat' ){
                aligned_ch = BLAT(
                        ch_source,
                        ch_target,
                        preproc_ch.pairspath_ch,
                        preproc_ch.tgt_lift,
                        preproc_ch.src_lift,
                        preproc_ch.twoBitS,
                        preproc_ch.twoBitT,
                        preproc_ch.twoBitSN,
                        preproc_ch.twoBitTN
                )
        } else if ( params.aligner == 'minimap2' ){
                aligned_ch = MINIMAP2(
                        ch_source,
                        ch_target,
                        preproc_ch.pairspath_ch,
                        preproc_ch.tgt_lift,
                        preproc_ch.src_lift,
                        preproc_ch.twoBitS,
                        preproc_ch.twoBitT,
                        preproc_ch.twoBitSN,
                        preproc_ch.twoBitTN
                )
        } else if ( params.aligner == 'gsalign' | params.aligner == 'GSAlign' ){
                aligned_ch = GSALIGN(
                        ch_source,
                        ch_target,
                        preproc_ch.pairspath_ch,
                        preproc_ch.tgt_lift,
                        preproc_ch.src_lift,
                        preproc_ch.twoBitS,
                        preproc_ch.twoBitT,
                        preproc_ch.twoBitSN,
                        preproc_ch.twoBitTN
                )
        }
        if (params.annotation) {
                if (!file(params.annotation).exists()) exit 0, "Genome annotation file ${params.annotation} not found. Closing."
                ch_annot = Channel.fromPath(params.annotation)
                LIFTOVER(aligned_ch.liftover, ch_annot, ch_target) 
                liftstats = LIFTOVER.out
        } else {
                liftstats = file("${params.outdir}/stats/placeholder4")
        }
        if (params.report){
                rmd = Channel.fromPath("${baseDir}/assets/gatherMetrics.Rmd")
                make_report(aligned_ch.mafs, aligned_ch.mafc, aligned_ch.mafi, liftstats, rmd)
        }
}
