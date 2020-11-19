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
if ( params.custom != '' && params.distance == 'custom' ) {
    params.distance = 'custom' }

// Print run informations
log.info """\
        __           _      ____  
       / _|         | |    / __ \ 
 _ __ | |_   ______ | |   | |  | |
| '_ \|  _| /_____/ | |   | |  | |
| | | | |           | |___| |__| |
|_| |_|_|           |______\____/ 
      
UCSC-like LiftOver v 1.4
================================
source         : $params.source
target         : $params.target
aligner        : $params.aligner
distance       : $params.distance
custom align   : $params.custom
custom chain   : $params.customChain
target chunk   : $params.tgtSize
source chunk   : $params.srcSize
source overlap : $params.srcOvlp
output folder  : $params.outdir
annot          : $params.annotation

""" 

// Check parameters
checkPathParamList = [
    params.source, params.target ]
for (param in checkPathParamList) { if (param) { file(param, checkIfExists: true) } }

/* Check mandatory params */
if (params.source) { ch_source = file(params.source) } else { exit 1, 'Source genome not specified!' }
if (params.target) { ch_target = file(params.target) } else { exit 1, 'Target genome not specified!' }

/*
include {PREPROCESS} from './modules/subworkflows/preprocess' params(params)

include {POSTPROC} from './modules/subworkflows/postprocess'
*/

workflow {
        if ( params.aligner == 'lastz' ){
                include {LASTZ as WORKER} from './modules/subworkflows/lastz' params(params)
        } else if ( params.aligner == 'last' ){
                include {LAST as WORKER} from './modules/subworkflows/last' params(params)
        } else if ( params.aligner == 'blat' ){
                include {BLAT as WORKER} from './modules/subworkflows/blat' params(params)
        } else if ( params.aligner == 'minimap2' ){
                include {MINIMAP2 as WORKER} from './modules/subworkflows/minimap2' params(params)
        }
        WORKER()
}

/*
workflow {
        main:
                PREPROCESS()
                ALIGN( PREPROCESS.out.[0], PREPROCESS.out.[1], PREPROCESS.out.[2], PREPROCESS.out.[3], PREPROCESS.out.[4]],
                        PREPROCESS.out.[5]], PREPROCESS.out.[6]] )
                POSTPROC(ALIGN.out, PREPROCESS.out.twoBsrc, PREPROCESS.out.twoBtgt, PREPROCESS.out.twoBsrcNFO, PREPROCESS.out.twoBtgtNFO)
        emit:
                POSTPROC.out
}
*/