//Processes for blat alignments

process blat_near {
    tag "blat.${params.distance}.${srcname}.${tgtname}"
    label 'medium'

    input:
    tuple val(srcname), path(srcfile), val(tgtname), path(tgtfile)
    path tgtlift 
    path srclift 
    path ooc11
    path ooc12

    output: 
    tuple val(srcname), val(tgtname), file("${srcname}.${tgtname}.psl"), emit: al_files_ch

    script:
    def blat_args = "-t=dna -q=dna -fastMap -noHead -tileSize=11 -minScore=100 -minIdentity=98"
    """
    blat ${srcfile} ${tgtfile} ${blat_args} -ooc=${ooc11} -out=psl tmp.psl 
    liftUp -type=.psl stdout $srclift warn tmp.psl |
        liftUp -type=.psl -pslQ ${srcname}.${tgtname}.psl $tgtlift warn stdin 
    """
  
    stub:
    """
    touch ${srcname}.${tgtname}.psl
    """
}


process blat_medium{    
    tag "blat.${params.distance}.${srcname}.${tgtname}"
    label 'medium'

    input: 
        tuple val(srcname), path(srcfile), val(tgtname), path(tgtfile) 
        path tgtlift 
        path srclift 
        path ooc11
        path ooc12

    output: 
        tuple val(srcname), val(tgtname), file("${srcname}.${tgtname}.psl"), emit: al_files_ch
  

    script:
    def blat_args = "-t=dna -q=dna -fastMap -noHead -tileSize=11 -stepSize=11 -oneOff=0 -minMatch=2 -minScore=30 -minIdentity=90 -maxGap=2 -maxIntron=75000"
    """
    blat ${srcfile} ${tgtfile} ${blat_args} -ooc=${ooc11} -out=psl tmp.psl 
    liftUp -type=.psl stdout $srclift warn tmp.psl |
        liftUp -type=.psl -pslQ ${srcname}.${tgtname}.psl $tgtlift warn stdin 
    """

    stub:
    """
    touch ${srcname}.${tgtname}.psl
    """
}


process blat_far{    
    tag "blat.${params.distance}.${srcname}.${tgtname}"
    label 'medium'

    input: 
        tuple val(srcname), path(srcfile), val(tgtname), path(tgtfile) 
        path tgtlift 
        path srclift 
        path ooc11
        path ooc12

    output: 
        tuple val(srcname), val(tgtname), file("${srcname}.${tgtname}.psl"), emit: al_files_ch
  
    script:
    def blat_args = "-t=dna -q=dna -fastMap -noHead -tileSize=12 -oneOff=1 -minMatch=1 -minScore=30 -minIdentity=80 -maxGap=3 -maxIntron=75000"
    """
    blat ${srcfile} ${tgtfile} ${blat_args} -ooc=${ooc12} -out=psl tmp.psl 
    liftUp -type=.psl stdout $srclift warn tmp.psl |
        liftUp -type=.psl -pslQ ${srcname}.${tgtname}.psl $tgtlift warn stdin 
    """

    stub:
    """
    touch ${srcname}.${tgtname}.psl
    """
}


process blat_balanced{    
    tag "blat.${params.distance}.${srcname}.${tgtname}"
    label 'medium'

    input: 
        tuple val(srcname), path(srcfile), val(tgtname), path(tgtfile) 
        path tgtlift 
        path srclift 
        path ooc11
        path ooc12

    output: 
        tuple val(srcname), val(tgtname), file("${srcname}.${tgtname}.psl"), emit: al_files_ch

    script:
    def blat_args = "-fastMap -tileSize=12 -minIdentity=98"
    """
    blat ${srcfile} ${tgtfile} ${blat_args} -ooc=${ooc12} -out=psl tmp.psl 
    liftUp -type=.psl stdout $srclift warn tmp.psl |
        liftUp -type=.psl -pslQ ${srcname}.${tgtname}.psl $tgtlift warn stdin 
    """
  
    stub:
    """
    touch ${srcname}.${tgtname}.psl
    """
}


process blat {    
    tag "blat.${params.distance}.${srcname}.${tgtname}"
    label 'medium'

    input: 
        tuple val(srcname), path(srcfile), val(tgtname), path(tgtfile) 
        path tgtlift 
        path srclift 
        path ooc11
        path ooc12

    output: 
        tuple val(srcname), val(tgtname), file("${srcname}.${tgtname}.psl"), emit: al_files_ch

    script:
    def blat_args = "-fastMap -tileSize=12 -minIdentity=98"
    if (params.custom) {
        blat_args = params.custom
    } else if (params.distance == 'near'){
        blat_args = "-t=dna -q=dna -fastMap -noHead -tileSize=11 -minScore=100 -minIdentity=98"
    } else if (params.distance == 'medium'){
        blat_args = "-t=dna -q=dna -fastMap -noHead -tileSize=11 -stepSize=11 -oneOff=0 -minMatch=2 -minScore=30 -minIdentity=90 -maxGap=2 -maxIntron=75000"
    } else if (params.distance == 'far') {
        blat_args = "-t=dna -q=dna -fastMap -noHead -tileSize=12 -oneOff=1 -minMatch=1 -minScore=30 -minIdentity=80 -maxGap=3 -maxIntron=75000"
    } else if (params.distance == 'balanced') {
        blat_args = "-fastMap -tileSize=12 -minIdentity=98"
    } else {
        blat_args = "-fastMap -tileSize=12 -minIdentity=98"
        log.info"""Preset ${params.distance} not available for blat"""   
        log.info"""The software will use the balanced instead."""   
        log.info"""If it is not ok for you, re-run selecting among the following options:"""   
        log.info""" 1 - near"""   
        log.info""" 2 - medium"""   
        log.info""" 3 - far"""   
        log.info""" 4 - balanced"""   
    }
    """
    blat ${srcfile} ${tgtfile} ${blat_args} -ooc=${ooc12} -out=psl tmp.psl 
    liftUp -type=.psl stdout $srclift warn tmp.psl |
        liftUp -type=.psl -pslQ ${srcname}.${tgtname}.psl $tgtlift warn stdin 
    """
  
    stub:
    """
    touch ${srcname}.${tgtname}.psl
    """
}
