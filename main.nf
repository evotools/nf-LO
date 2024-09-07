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
 
// Show help message
if (params.help) {
    include {helpMessage} from './modules/processes/help.nf'
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
mamba           : $params.mamba
no_maf          : $params.no_maf"""
if (params.qscores){
        log.info"""q-scores        : $params.qscores"""
} 
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
log.info"""skip netsynt    : $params.no_netsynt
max cpu         : $params.max_cpus
max mem         : $params.max_memory
max rt          : $params.max_time""" 
if (workflow.containerEngine){
        log.info """container       : $workflow.containerEngine"""
} 

// Check parameters
// checkPathParamList = [
//     params.source, params.target ]
// for (param in checkPathParamList) { if (param) { file(param, checkIfExists: true) } }

/* Check mandatory params */
if ( params.aligner == 'lastz' ){
        include {LASTZ as ALIGNER} from './modules/subworkflows/lastz' params(params)
} else if ( params.aligner == 'blat' ){
        include {BLAT as ALIGNER} from './modules/subworkflows/blat' params(params)
} else if ( params.aligner == 'minimap2' ){
        include {MINIMAP2 as ALIGNER} from './modules/subworkflows/minimap2' params(params)
} else if ( params.aligner == 'gsalign' | params.aligner == 'GSAlign' ){
        include {GSALIGN as ALIGNER} from './modules/subworkflows/GSAlign' params(params)
}
include {PREPROC} from './modules/subworkflows/preprocess' params(params)
include {LIFTOVER} from './modules/subworkflows/liftover' params(params)
include {DATA} from './modules/subworkflows/data' params(params)
include {make_report} from './modules/processes/postprocess' params(params)
include {maf2mfa; mfa2vcf} from "./modules/processes/postprocess" params(params)
workflow {
        DATA()
        ch_source = DATA.out.ch_source
        ch_target = DATA.out.ch_target
        PREPROC( ch_source, ch_target )
        ALIGNER( ch_source, ch_target, PREPROC.out )
        if (params.annotation) {
                if (!file(params.annotation).exists()) exit 0, "Genome annotation file ${params.annotation} not found. Closing."
                ch_annot = Channel.fromPath(params.annotation)
                LIFTOVER(ALIGNER.out[0], ch_annot, ch_target) 
                liftstats = LIFTOVER.out
        } else {
                liftstats = file("${params.outdir}/stats/placeholder4")
        }
        if (params.mafTools || params.annotation || workflow.containerEngine){
                rmd = Channel.fromPath("${baseDir}/assets/gatherMetrics.Rmd")
                make_report(ALIGNER.out.mafs, ALIGNER.out.mafc, ALIGNER.out.mafi, liftstats, rmd)

                // Make VCF file
        }
        if (params.vcf){
                maf2mfa(ALIGNER.out.maf, ch_source, ch_target) | mfa2vcf
        }
}
