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
params.distance = 'medium'
params.aligner = 'lastz'
params.tgtSize = 1000000
params.srcSize = 500000
params.srcOvlp=100000
params.outdir = "${baseDir}/OUTPUTS" 
params.annotation = 'NO_FILE'

log.info """\
UCSC-like LiftOver v 1.3 
================================
source         : $params.source
target         : $params.target
aligner        : $params.aligner
distance       : $params.distance
target chunk   : $params.tgtSize
source chunk   : $params.srcSize
source overlap : $params.srcOvlp
output folder  : $params.outdir
annot          : $params.annotation

"""

tgtChunkSize=params.tgtSize
srcChunkSize=params.srcSize
srcOvlpSize=params.srcOvlp

chainNear="-minScore=5000 -linearGap=medium"
chainMedium="-minScore=3000 -linearGap=medium"
chainFar="-minScore=5000 -linearGap=loose"
lastzNear="B=0 C=0 E=150 H=0 K=4500 L=3000 M=254 O=600 T=2 Y=15000"
lastzMedium="B=0 C=0 E=30 H=0 K=3000 L=3000 M=50 O=400 T=1 Y=9400"
lastzFar="B=0 C=0 E=30 H=2000 K=2200 L=6000 M=50 O=400 T=2 Y=3400"
blatFast="-fastMap -tileSize=12 -minIdentity=98"
blatNear="-t=dna -q=dna -fastMap -noHead -tileSize=11 -minScore=100 -minIdentity=98"
blatMedium="-t=dna -q=dna -fastMap -noHead -tileSize=11 -stepSize=11 -oneOff=0 -minMatch=2 -minScore=30 -minIdentity=90 -maxGap=2 -maxIntron=75000"
blatFar="-t=dna -q=dna -fastMap -noHead -tileSize=12 -oneOff=1 -minMatch=1 -minScore=30 -minIdentity=80 -maxGap=3 -maxIntron=75000"
minimap2Near="-cx asm5"
minimap2Medium="-cx asm10"
minimap2Far="-cx asm20"

/*
 * Step 1. Builds the genome index required by the mapping process and
 * the intervals for the analyses
 */

process make2bit {
    tag "twoBit"
    publishDir "$params.outdir/genome2bit"

    cpus { 1 * task.attempt }
    memory { 8.GB * task.attempt }
    time { 6.hour * task.attempt }
    clusterOptions "-P roslin_ctlgh -l h_vmem=${task.memory.toString().replaceAll(/[\sB]/,'')}"

    output:
    file "source.2bit" into twoBsrc_ch
    file "target.2bit" into twoBtgt_ch
    file "source.2bit" into twoBsrc_ch2
    file "target.2bit" into twoBtgt_ch2
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
    publishDir "$params.outdir/splitfa_src"

    cpus { 1 * task.attempt }
    memory { 16.GB * task.attempt }
    time { 12.hour * task.attempt }
    clusterOptions "-P roslin_ctlgh -l h_vmem=${task.memory.toString().replaceAll(/[\sB]/,'')}"

    output:
    path "SPLIT_src" into srcsplit_ch
    file "source.lift" into src_lift_ch
    file "11.ooc" optional true into ooc11_ch
    file "12.ooc" optional true into ooc12_ch

    script:
    if (params.aligner != "blat")
    """
    mkdir ./SPLIT_src && chmod a+rw ./SPLIT_src
    faSplit size -lift=source.lift -extra=${srcOvlpSize} ${params.source} ${srcChunkSize} SPLIT_src/
    """
    else
    """
    blat ${params.source} /dev/null /dev/null -makeOoc=11.ooc -repMatch=1024
    blat ${params.source} /dev/null /dev/null -makeOoc=12.ooc -repMatch=1024 -tileSize=12
    mkdir ./SPLIT_src && chmod a+rw ./SPLIT_src
    faSplit size -lift=source.lift -extra=${srcOvlpSize} ${params.source} ${srcChunkSize} SPLIT_src/
    """
}
src_lift_ch.into{ src_lift_chL; src_lift_chB; src_lift_chM }


process groupsrc {
    tag "groupsrc"
    publishDir "$params.outdir/groupedfa_src"

    cpus { 1 * task.attempt }
    memory { 8.GB * task.attempt }
    time { 6.hour * task.attempt }
    clusterOptions "-P roslin_ctlgh -l h_vmem=${task.memory.toString().replaceAll(/[\sB]/,'')}"

    input:
    path src_fld from srcsplit_ch

    output:
    path "./CLUST_src" into srcclst_ch
    path "./CLUST_src" into srcclst_ch2

    script:
    $/
    #!/usr/bin/env python

    def faSize(infile):
        return sum([len(line.strip()) for line in open(infile) if ">" not in line])


    if __name__ == "__main__":
        import os
        infld=os.path.realpath( "${src_fld}" )
        outFld = "./CLUST_src"
        os.mkdir(outFld)
        if not os.path.exists(outFld): os.mkdir(outFld)

        flist = os.listdir(infld)
        sizes = [faSize(os.path.join(infld, f)) for f in flist]
        tmpdata = list(zip(sizes,flist))
        tmpdata.sort(reverse = True)
        total = 0
        n = 0
        fname = "{}/src{}.fa"
        toWrite = []

        for n,(size,seq) in enumerate(tmpdata):
            total += size
            if total < int(${params.srcSize}):
                toWrite.append(os.path.join(infld, seq))
            else:
                if len(toWrite) > 0: 
                    outf = open(fname.format(outFld, n), "w" )
                    [outf.write(line) for f in toWrite for line in open(f) ]
                    outf.close()
                n += 1
                toWrite = [os.path.join(infld, seq)]
                total = size
        outf = open(fname.format(outFld, n), "w" )
        [outf.write(line) for f in toWrite for line in open(f) ]
        outf.close()
    /$

}


process splittgt {
    tag "splittgt"
    publishDir "$params.outdir/splitfa_tgt"

    cpus { 1 * task.attempt }
    memory { 8.GB * task.attempt }
    time { 6.hour * task.attempt }
    clusterOptions "-P roslin_ctlgh -l h_vmem=${task.memory.toString().replaceAll(/[\sB]/,'')}"


    output:
    path "SPLIT_tgt" into tgtsplit_ch
    file "target.lift" into tgt_lift_ch

    script:
    if( params.aligner == "blat" )
        """
        mkdir ./SPLIT_tgt && chmod a+rw ./SPLIT_tgt
        faSplit size -oneFile -lift=target.lift -extra=500 ${params.target} 4500 SPLIT_tgt/tmp
        """
    else
        """
        mkdir SPLIT_tgt && chmod a+rw SPLIT_tgt
        faSplit size -lift=target.lift ${params.target} ${tgtChunkSize} SPLIT_tgt/
        """
}
tgt_lift_ch.into{ tgt_lift_chL; tgt_lift_chB; tgt_lift_chM }

process grouptgt {
    tag "grouptgt"
    publishDir "$params.outdir/groupedfa_tgt"

    cpus { 1 * task.attempt }
    memory { 8.GB * task.attempt }
    time { 6.hour * task.attempt }
    clusterOptions "-P roslin_ctlgh -l h_vmem=${task.memory.toString().replaceAll(/[\sB]/,'')}"

    input:
    path tgt_fld from tgtsplit_ch

    output:
    path "./CLUST_tgt" into tgtclst_ch
    path "./CLUST_tgt" into tgtclst_ch2

    script:
    if( params.aligner != "blat" )
    $/
    #!/usr/bin/env python

    def faSize(infile):
        return sum([len(line.strip()) for line in open(infile) if ">" not in line])


    if __name__ == "__main__":
        import os
        infld=os.path.realpath( "${tgt_fld}" )
        outFld = "./CLUST_tgt"
        if not os.path.exists(outFld): os.mkdir(outFld)

        flist = os.listdir(infld)
        sizes = [faSize(os.path.join(infld, f)) for f in flist]
        tmpdata = list(zip(sizes,flist))
        tmpdata.sort(reverse = True)
        total = 0
        n = 0
        fname = "./{}/tgt{}.fa"
        toWrite = []
        for n,(size,seq) in enumerate(tmpdata):
            total += size
            if total < int(${params.srcSize}):
                toWrite.append(os.path.join(infld, seq))
            else:
                if len(toWrite) > 0: 
                    outf = open(fname.format(outFld, n), "w" )
                    [outf.write(line) for f in toWrite for line in open(f) ]
                    outf.close()
                n += 1
                toWrite = [os.path.join(infld, seq)]
                total = size
        outf = open(fname.format(outFld, n), "w" )
        [outf.write(line) for f in toWrite for line in open(f) ]
        outf.close()
    /$
    else    
    $/
    #!/usr/bin/env python

    if __name__ == "__main__":
        import os
        infld=os.path.realpath( "${tgt_fld}" )
        outFld = "./CLUST_tgt"
        os.mkdir(outFld)
        if not os.path.exists(outFld): os.mkdir(outFld)

        fasta = os.listdir(infld)[0]
        nseqs = sum([1 for i in open(os.path.join("${tgt_fld}", fasta)) if ">" in i])
        totalL = sum([len(i.strip()) for i in open(os.path.join("${tgt_fld}", fasta)) if ">" not in i])
        nseqXfile = nseqs / round(int(totalL / int("${params.tgtSize}")))
        n = 1
        tot = 0
        fname = "{}/tgt{}.fa"
        toWrite = []
        outf = open(fname.format(outFld, n), "w" )
        for line in open(os.path.join("${tgt_fld}", fasta)):
            if ">" in line:
                tot += 1
            if tot > nseqXfile:
                outf.close()
                n += 1
                outf = open(fname.format(outFld, n), "w" )
                tot = 1
            outf.write(line)
    /$

}

/*
 * Step 2: Make pairs of chromosomes to process
 */

process pairs {
    tag "mkpairs"

    cpus { 1 * task.attempt }
    memory { 8.GB * task.attempt }
    time { 6.hour * task.attempt }
    clusterOptions "-P roslin_ctlgh -l h_vmem=${task.memory.toString().replaceAll(/[\sB]/,'')}"

    input:
    path sources from srcclst_ch
    path targets from tgtclst_ch

    output:
    path "pairs.csv" into pairspath

    $/
    #!/usr/bin/env python
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
 * Make alignments.
 * Aligner process is chosen based on params.aligner
 * Parameters are chosen based on params.distance internally
 */

pairspath_ch.into{ forlastz_ch; forblat_ch; forminimap2_ch; fornucmer_ch; forlast_ch }

process lastz{    
    tag "lastz.${srcname}.${tgtname}"
    publishDir "${params.outdir}/alignments"

    cpus { 1 * task.attempt }
    memory { 8.GB * task.attempt }
    time { 24.hour * task.attempt }
    clusterOptions "-P roslin_ctlgh -l h_vmem=${task.memory.toString().replaceAll(/[\sB]/,'')}"

    input: 
        set srcname, srcfile, tgtname, tgtfile from forlastz_ch  
        file tgtlift from tgt_lift_chL
        file srclift from src_lift_chL

    output: 
        tuple srcname, tgtname, "${srcname}.${tgtname}.psl" into al_files_chL

    when:
        params.aligner == "lastz"
  
    script:
    if( params.distance == 'near')
        """
        echo $lastzNear
        lastz ${srcfile} ${tgtfile} ${lastzNear} --format=lav |
            lavToPsl stdin stdout |
                liftUp -type=.psl stdout $srclift warn stdin |
                    liftUp -type=.psl -pslQ ${srcname}.${tgtname}.psl $tgtlift warn stdin 
        """
    else if( params.distance == 'medium')
        """
        echo $lastzMedium
        lastz ${srcfile} ${tgtfile} ${lastzMedium} --format=lav |
            lavToPsl stdin stdout |
                liftUp -type=.psl stdout $srclift warn stdin |
                    liftUp -type=.psl -pslQ ${srcname}.${tgtname}.psl $tgtlift warn stdin 
        """
    else if( params.distance == 'far')
        """
        echo $lastzFar
        lastz ${srcfile} ${tgtfile} ${lastzFar} --format=lav |
            lavToPsl stdin stdout |
                liftUp -type=.psl stdout $srclift warn stdin |
                    liftUp -type=.psl -pslQ ${srcname}.${tgtname}.psl $tgtlift warn stdin 
        """
    else
        """
        echo "Distance not recognised"
        """

}

process blat{    
    tag "blat.${srcname}.${tgtname}"
    publishDir "${params.outdir}/alignments"

    cpus { 1 * task.attempt }
    memory { 8.GB * task.attempt }
    time { 24.hour * task.attempt }
    clusterOptions "-P roslin_ctlgh -l h_vmem=${task.memory.toString().replaceAll(/[\sB]/,'')}"

    input: 
        set srcname, srcfile, tgtname, tgtfile from forblat_ch  
        file tgtlift from tgt_lift_chB
        file srclift from src_lift_chB
        file ooc11 from ooc11_ch
        file ooc12 from ooc12_ch

    output: 
        tuple srcname, tgtname, "${srcname}.${tgtname}.psl" into al_files_chB

    when:
        params.aligner == "blat"
  
    script:
    if( params.distance == 'fast' )
        """
        blat ${srcfile} ${tgtfile} ${blatFast} -ooc=${ooc12} -out=psl tmp.psl 
        liftUp -type=.psl stdout $srclift warn tmp.psl |
            liftUp -type=.psl -pslQ ${srcname}.${tgtname}.psl $tgtlift warn stdin 
        """
    else if( params.distance == 'near' )
        """
        blat ${srcfile} ${tgtfile} ${blatNear} -ooc=${ooc11} -out=psl tmp.psl 
        liftUp -type=.psl stdout $srclift warn tmp.psl |
            liftUp -type=.psl -pslQ ${srcname}.${tgtname}.psl $tgtlift warn stdin 
        """
    else if( params.distance == 'medium' )
        """
        blat ${srcfile} ${tgtfile} ${blatMedium} -ooc=${ooc11} -out=psl tmp.psl 
        liftUp -type=.psl stdout $srclift warn tmp.psl |
            liftUp -type=.psl -pslQ ${srcname}.${tgtname}.psl $tgtlift warn stdin 
        """
    else if( params.distance == 'far' )
        """
        blat ${srcfile} ${tgtfile} ${blatFar} -ooc=${ooc12} -out=psl tmp.psl 
        liftUp -type=.psl stdout $srclift warn tmp.psl |
            liftUp -type=.psl -pslQ ${srcname}.${tgtname}.psl $tgtlift warn stdin 
        """
    else
        """
        echo "Distance not recognised"
        """

}

process minimap2{    
    tag "minimap2.${srcname}.${tgtname}"
    publishDir "${params.outdir}/alignments"

    cpus { 2 * task.attempt }
    memory { 8.GB * task.attempt }
    time { 12.hour * task.attempt }
    clusterOptions "-P roslin_ctlgh -l h_vmem=${task.memory.toString().replaceAll(/[\sB]/,'')}"

    input: 
        set srcname, srcfile, tgtname, tgtfile from forminimap2_ch  
        file tgtlift from tgt_lift_chM
        file srclift from src_lift_chM

    output: 
        tuple srcname, tgtname, "${srcname}.${tgtname}.psl" into al_files_chM

    when:
        params.aligner == "minimap2"
  
    script:
    if( params.distance == 'near' )
        """
        minimap2 -t ${task.cpus} --cs=long ${srcfile} ${tgtfile} ${minimap2Near} | 
            paftools.js view -f maf - |
            maf-convert psl - |
            liftUp -type=.psl stdout $srclift warn stdin |
            liftUp -type=.psl -pslQ ${srcname}.${tgtname}.psl $tgtlift warn stdin 
        """
    else if( params.distance == 'medium' )
        """
        minimap2 -t ${task.cpus} --cs=long ${srcfile} ${tgtfile} ${minimap2Medium} | 
            paftools.js view -f maf - |
            maf-convert psl - |
            liftUp -type=.psl stdout $srclift warn stdin |
            liftUp -type=.psl -pslQ ${srcname}.${tgtname}.psl $tgtlift warn stdin 
        """
    else if( params.distance == 'far' )
        """
        minimap2 -t ${task.cpus} --cs=long ${srcfile} ${tgtfile} ${minimap2Far} | 
            paftools.js view -f maf - |
            maf-convert psl - |
            liftUp -type=.psl stdout $srclift warn stdin |
            liftUp -type=.psl -pslQ ${srcname}.${tgtname}.psl $tgtlift warn stdin 
        """
    else
        """
        echo "Distance not recognised"
        """

}


process nucmer{    
    tag "nucmer.${srcname}.${tgtname}"
    publishDir "${params.outdir}/alignments"

    cpus { 4 * task.attempt }
    memory { 16.GB * task.attempt }
    time { 12.hour * task.attempt }
    clusterOptions "-P roslin_ctlgh -l h_vmem=${task.memory.toString().replaceAll(/[\sB]/,'')}"

    input: 
        set srcname, srcfile, tgtname, tgtfile from fornucmer_ch  
        file tgtlift from tgt_lift_chM
        file srclift from src_lift_chM

    output: 
        tuple srcname, tgtname, "${srcname}.${tgtname}.psl" into al_files_chN

    when:
        params.aligner == "nucmer"
  
    script:
    """
    nucmer -t ${task.cpus} --prefix=${refName}.${queryName} ${reference} ${query}
    paftools.js delta2paf {refName}.${queryName} |
        paftools.js view -f maf - |
        maf-convert psl - |
        liftUp -type=.psl stdout $srclift warn stdin |
        liftUp -type=.psl -pslQ ${srcname}.${tgtname}.psl $tgtlift warn stdin 
    """
}

process last{    
    tag "last.${srcname}.${tgtname}"
    publishDir "${params.outdir}/alignments"

    cpus { 1 * task.attempt }
    memory { 8.GB * task.attempt }
    time { 24.hour * task.attempt }
    clusterOptions "-P roslin_ctlgh -l h_vmem=${task.memory.toString().replaceAll(/[\sB]/,'')}"

    input: 
        set srcname, srcfile, tgtname, tgtfile from forlast_ch  
        file tgtlift from tgt_lift_chM
        file srclift from src_lift_chM

    output: 
        tuple srcname, tgtname, "${srcname}.${tgtname}.psl" into al_files_chS

    when:
        params.aligner == "last"
  
    script:
    """
    lastdb localDB ${srcfile}
    lastal localDB ${tgtfile} ${minimap2Near} | 
        maf-convert psl - |
        liftUp -type=.psl stdout $srclift warn stdin |
        liftUp -type=.psl -pslQ ${srcname}.${tgtname}.psl $tgtlift warn stdin && rm localDB
    """
}


if ( params.aligner == "lastz" ){
    al_files_chL.set{ al_files_ch }
} else if ( params.aligner == "blat" ) {
    al_files_chB.set{ al_files_ch }
} else if ( params.aligner == "minimap2" ) {
    al_files_chM.set{ al_files_ch }
} else if ( params.aligner == "nucmer" ) {
    al_files_chN.set{ al_files_ch }
} else if ( params.aligner == "last" ) {
    al_files_chS.set{ al_files_ch }
}

/*
 * Combine and process outputs 
 */

process axtchain {
    tag "axtchain"
    publishDir "${params.outdir}/singlechains"

    cpus { 1 * task.attempt }
    memory { 32.GB * task.attempt }
    time { 12.hour * task.attempt }
    clusterOptions "-P roslin_ctlgh -l h_vmem=${task.memory.toString().replaceAll(/[\sB]/,'')}"

    input:
        tuple srcname, tgtname, psl from al_files_ch
        file twoBitS from twoBsrc_ch2
        file twoBitT from twoBtgt_ch2

    output:
        file "${srcname}.${tgtname}.chain" into chain_files_ch

    script:
    if( params.distance == 'near' )
    """
    axtChain $chainNear -verbose=0 -psl $psl ${twoBitS} ${twoBitT} stdout | chainAntiRepeat ${twoBitS} ${twoBitT} stdin stdout > ${srcname}.${tgtname}.chain
    """
    else if (params.distance == 'medium')
    """
    axtChain $chainMedium -verbose=0 -psl $psl ${twoBitS} ${twoBitT} stdout | chainAntiRepeat ${twoBitS} ${twoBitT} stdin stdout > ${srcname}.${tgtname}.chain
    """
    else if (params.distance == 'far')
    """
    axtChain $chainFar -verbose=0 -psl $psl ${twoBitS} ${twoBitT} | chainAntiRepeat ${twoBitS} ${twoBitT} stdin stdout > ${srcname}.${tgtname}.chain
    """
}


process chainMerge {
    tag "chainmerge"
    publishDir "${params.outdir}/rawchain", mode: 'copy', overwrite: true

    cpus { 1 * task.attempt }
    memory { 32.GB * task.attempt }
    time { 24.hour * task.attempt }
    clusterOptions "-P roslin_ctlgh -l h_vmem=${task.memory.toString().replaceAll(/[\sB]/,'')}"
 
    input: 
        file chains from chain_files_ch.collect()
        
    output: 
        file "rawchain.chain" into rawchain_ch  
  
    script:
    """
    chainMergeSort $chains | chainSplit run stdin -lump=1 
    mv run/000.chain ./rawchain.chain
    """
}

process chainNet{
    tag "chainnet"
    publishDir "${params.outdir}/chainnet", mode: 'copy', overwrite: true

    cpus { 1 * task.attempt }
    memory { 32.GB * task.attempt }
    time { 24.hour * task.attempt }
    clusterOptions "-P roslin_ctlgh -l h_vmem=${task.memory.toString().replaceAll(/[\sB]/,'')}"
 
    input:
        file rawchain from rawchain_ch  
        file twoBitS from twoBsrc_ch
        file twoBitT from twoBtgt_ch
        file twoBitsizeS from twoBsrcNFO_ch
        file twoBitsizeT from twoBtgtNFO_ch
        
    output: 
        file "liftover.chain" into liftover_ch  
        file "netfile.net" into netfile_ch  
  
    script:
    if ( params.aligner != "blat" & params.aligner != "nucmer" )
    """
    chainPreNet ${rawchain} ${twoBitsizeS} ${twoBitsizeT} stdout |
        chainNet -verbose=0 stdin ${twoBitsizeS} ${twoBitsizeT} stdout /dev/null |
        netSyntenic stdin netfile.net
    netChainSubset -verbose=0 netfile.net ${rawchain} stdout | chainStitchId stdin stdout > liftover.chain
    """
    else
    """
    chainPreNet ${rawchain} ${twoBitsizeS} ${twoBitsizeT} stdout |
        chainNet -verbose=0 stdin ${twoBitsizeS} ${twoBitsizeT} netfile.net /dev/null 
    netChainSubset -verbose=0 netfile.net ${rawchain} stdout | chainStitchId stdin liftover.chain
    """
}


process liftover{
    tag "liftover"
    publishDir "${params.outdir}/lifted", mode: 'copy', overwrite: true

    cpus { 1 * task.attempt }
    memory { 32.GB * task.attempt }
    time { 12.hour * task.attempt }
    clusterOptions "-P roslin_ctlgh -l h_vmem=${task.memory.toString().replaceAll(/[\sB]/,'')}"
 
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
