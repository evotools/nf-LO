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

// Print run informations
log.info '''
=====================================
         __           _      ____  
        / _|         | |    / __ \\ 
  _ __ | |_   ______ | |   | |  | |
 | '_ \\|  _| |_____| | |   | |  | |
 | | | | |           | |___| |__| |
 |_| |_|_|           |______\\____/ 
=====================================
      '''
log.info """\
Nextflow LiftOver v 1.5.0a
====================================="""
if (params.ncbi_source){
        log.info"""source          : $params.ncbi_source (NCBI)"""
} else if (params.igenome_source) {
        log.info"""source          : $params.igenome_source (iGenome)"""
} else {
        log.info"""source          : $params.source"""
}
if (params.ncbi_target){
        log.info"""target          : $params.ncbi_target (NCBI)"""
} else if (params.igenome_target) {
        log.info"""target          : $params.igenome_target (iGenome)"""
} else {
        log.info"""target          : $params.target"""
}
log.info"""aligner         : $params.aligner
distance        : $params.distance
custom align    : $params.custom
custom chain    : $params.chainCustom
source chunk    : $params.srcSize
target chunk    : $params.tgtSize
target overlap  : $params.tgtOvlp
output folder   : $params.outdir
liftover name   : $params.chain_name
annot           : $params.annotation
annot type      : $params.annotation_format
liftover meth.  : $params.liftover_algorithm
igenomes_base   : $params.igenomes_base
igenomes_ignore : $params.igenomes_ignore
no_maf          : $params.no_maf
""" 

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

workflow {
        DATA()
        ch_source = DATA.out[0]
        ch_target = DATA.out[1]
        PREPROC( ch_source, ch_target )
        ALIGNER( PREPROC.out )
        if (params.annotation) {
                if (!file(params.annotation).exists()) exit 0, "Genome annotation file ${params.annotation} not found. Closing."
                ch_annot = Channel.fromPath(params.annotation)
                LIFTOVER(ALIGNER.out[0], ch_annot, ch_target) 
        }                
}
