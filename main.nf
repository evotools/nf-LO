#!/usr/bin/env nextflow
 
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
params.source = 'genome1.fa'
params.target = 'genome2.fa'
params.alignerparam = '--hspthresh=3000 --transition --masking=0 --gap=400,30 --inner=2200 --gappedthresh=3000 --ambiguous=iupac'
params.outdir = "${baseDir}/OUTPUTS" 
params.annotation = 'NO_FILE'
params.aligner = 'lastz'

log.info """\
Liftover from source to target    v 1.0 
================================
source        : $params.source
target        : $params.target
aligner       : $params.aligner
parameters    : $params.alignerparam
output folder : $params.outdir
annot         : $params.annotation

"""

/*
 * Step 1. Builds the genome index required by the mapping process and
 * the intervals for the analyses
 */

process make2bit {
    tag "twoBit"

    output:
    file "source.2bit" into twoBsrc_ch
    file "target.2bit" into twoBtgt_ch
    file "source.sizes" into twoBsrcNFO_ch
    file "target.sizes" into twoBtgtNFO_ch

    script:
    """
    faToTwoBit ${params.source} source.2bit
    twoBitInfo source.2bit source.sizes
    faToTwoBit ${params.target} target.2bit
    twoBitInfo target.2bit target.sizes
    """
}

process splitsrc {
    tag "splitsrc"

    output:
    path "SPLIT_src" into srcsplit_ch

    script:
    """
    mkdir SPLIT_src && chmod a+rw SPLIT_src
    faSplit byname ${params.source} SPLIT_src/
    """

}

process splittgt {
    tag "splittgt"

    output:
    path "SPLIT_tgt" into tgtsplit_ch

    script:
    """
    mkdir SPLIT_tgt && chmod a+rw SPLIT_tgt
    faSplit byname ${params.target} SPLIT_tgt/
    """
}

/*
 * Step 2: Make pairs of chromosomes to process
 */

process pairs {
    tag "mkpairs"

    input:
    path sources from srcsplit_ch
    path targets from tgtsplit_ch

    output:
    path "pairs.csv" into pairspath

    $/
    #!/usr/bin/env python3
    import os
    infld1 = os.path.realpath( "${sources}" )
    infld2 = os.path.realpath( "${targets}" )
    files1 = os.listdir(infld1)
    files2 = os.listdir(infld2)
    of = open("pairs.csv", "w")
    for f in files1:
        fname1 = os.path.join( infld1, f)
        bname1= '.'.join( f.split('.')[0:-1] )
        for f2 in files2:
            fname2 = os.path.join(infld2, f2)
            bname2 = '.'.join( f2.split('.')[0:-1] )
            of.write( "{},{},{},{}\n".format(bname1, fname1, bname2, fname2) )
    /$
}

pairspath
    .splitCsv(header: ['srcname', 'srcfile', 'tgtname', 'tgtfile'])
    .map{ row-> tuple(row.srcname, row.srcfile, row.tgtname, row.tgtfile) }
    .set{ pairspath_ch }

/*
 * Make actual alignments
 */

process align { 
    tag "align.${srcname}.${tgtname}"

    input: 
        set srcname, srcfile, tgtname, tgtfile from pairspath_ch   

    output: 
        file "${srcname}.${tgtname}.axt.gz" into al_files_ch
  
    script:
    if( params.aligner == 'lastz' )
        """
        lastz ${tgtfile} ${srcfile} ${params.alignerparam} --format=axt | awk '\$1!~"#" {print}' | gzip -c > ${srcname}.${tgtname}.axt.gz
        """
    else if( params.aligner == 'blat' )
        """
        blat ${tgtfile} ${srcfile} ${params.alignerparam} -out=axt tmp.axt 
        cat tmp.axt | awk '\$1!~"#" {print}' | gzip -c > ${srcname}.${tgtname}.axt.gz
        """
}

process singleaxt {
    tag "oneaxt"
    publishDir "${params.outdir}/axt"

    input:
        file axts from al_files_ch.collect()

    output:
        file "axtfile.axt.gz" into axt_file_ch

    script:
    """
    for i in ${axts}; do
        gunzip -c \$i
    done | gzip -c > axtfile.axt.gz
    """
}


process axtchain {
    tag "axtchain"
    publishDir "${params.outdir}/chain"
 
    input: 
        file axt from axt_file_ch
        file twoBitS from twoBsrc_ch
        file twoBitT from twoBtgt_ch
        file twoBitsizeS from twoBsrcNFO_ch
        file twoBitsizeT from twoBtgtNFO_ch
        
    output: 
        file "liftover.chain.gz" into liftover_ch  
        file "netfile.net" into netfile_ch  
  
    script:
    """
    gunzip -c ${axt} | axtChain -verbose=0 -linearGap=medium stdin ${twoBitT} ${twoBitS} stdout | chainAntiRepeat ${twoBitT} ${twoBitS} stdin tmp1.chain
    chainMergeSort tmp1.chain | chainSplit run stdin -lump=1 
    mv run/000.chain ./tmp2.chain
    chainPreNet tmp2.chain ${twoBitsizeT} ${twoBitsizeS} stdout | \
        chainNet -verbose=0 stdin ${twoBitsizeT} ${twoBitsizeS} stdout /dev/null | \
        netSyntenic stdin netfile.net
    netChainSubset -verbose=0 netfile.net tmp2.chain stdout | chainStitchId stdin stdout | gzip -c > liftover.chain.gz
    """
}


process liftover{
    tag "liftover"
    publishDir "${params.outdir}/liftover"
 
    input:
        file liftover from liftover_ch

    output:
        file "lifted.bed" optional true into lifted_ch
        file "unmapped.bed" optional true into unmapped_ch

    script:
    if (params.annotation != 'NO_FILE' & params.annotation != '' )
        """
        liftOver ${params.annotation} ${liftover} lifted.bed unmapped.bed
        """
    else
        """
        echo "Nothing to be done"
        """
}
