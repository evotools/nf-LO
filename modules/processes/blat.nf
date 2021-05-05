//Processes for blat alignments

blatBalanced="-fastMap -tileSize=12 -minIdentity=98"
blatNear="-t=dna -q=dna -fastMap -noHead -tileSize=11 -minScore=100 -minIdentity=98"
blatMedium="-t=dna -q=dna -fastMap -noHead -tileSize=11 -stepSize=11 -oneOff=0 -minMatch=2 -minScore=30 -minIdentity=90 -maxGap=2 -maxIntron=75000"
blatFar="-t=dna -q=dna -fastMap -noHead -tileSize=12 -oneOff=1 -minMatch=1 -minScore=30 -minIdentity=80 -maxGap=3 -maxIntron=75000"


process blat_near{    
    tag "blat.${params.distance}.${srcname}.${tgtname}"
    label 'small'

    input: 
        tuple val(srcname), val(srcfile), val(tgtname), val(tgtfile) 
        file tgtlift 
        file srclift 
        file ooc11
        file ooc12

    output: 
        tuple val(srcname), val(tgtname), file("${srcname}.${tgtname}.psl"), emit: al_files_ch
  
    stub:
    """
    touch ${srcname}.${tgtname}.psl
    """

    script:
    """
    blat ${srcfile} ${tgtfile} ${blatNear} -ooc=${ooc11} -out=psl tmp.psl 
    liftUp -type=.psl stdout $srclift warn tmp.psl |
        liftUp -type=.psl -pslQ ${srcname}.${tgtname}.psl $tgtlift warn stdin 
    """
}


process blat_medium{    
    tag "blat.${params.distance}.${srcname}.${tgtname}"
    label 'small'

    input: 
        tuple val(srcname), val(srcfile), val(tgtname), val(tgtfile) 
        file tgtlift 
        file srclift 
        file ooc11
        file ooc12

    output: 
        tuple val(srcname), val(tgtname), file("${srcname}.${tgtname}.psl"), emit: al_files_ch
  
    stub:
    """
    touch ${srcname}.${tgtname}.psl
    """

    script:
    """
    blat ${srcfile} ${tgtfile} ${blatMedium} -ooc=${ooc11} -out=psl tmp.psl 
    liftUp -type=.psl stdout $srclift warn tmp.psl |
        liftUp -type=.psl -pslQ ${srcname}.${tgtname}.psl $tgtlift warn stdin 
    """
}


process blat_far{    
    tag "blat.${params.distance}.${srcname}.${tgtname}"
    label 'small'

    input: 
        tuple val(srcname), val(srcfile), val(tgtname), val(tgtfile) 
        file tgtlift 
        file srclift 
        file ooc11
        file ooc12

    output: 
        tuple val(srcname), val(tgtname), file("${srcname}.${tgtname}.psl"), emit: al_files_ch
  
    stub:
    """
    touch ${srcname}.${tgtname}.psl
    """

    script:
    """
    blat ${srcfile} ${tgtfile} ${blatFar} -ooc=${ooc12} -out=psl tmp.psl 
    liftUp -type=.psl stdout $srclift warn tmp.psl |
        liftUp -type=.psl -pslQ ${srcname}.${tgtname}.psl $tgtlift warn stdin 
    """
}


process blat_balanced{    
    tag "blat.${params.distance}.${srcname}.${tgtname}"
    label 'small'

    input: 
        tuple val(srcname), val(srcfile), val(tgtname), val(tgtfile) 
        file tgtlift 
        file srclift 
        file ooc11
        file ooc12

    output: 
        tuple val(srcname), val(tgtname), file("${srcname}.${tgtname}.psl"), emit: al_files_ch
  
    stub:
    """
    touch ${srcname}.${tgtname}.psl
    """

    script:
    """
    blat ${srcfile} ${tgtfile} ${blatBalanced} -ooc=${ooc12} -out=psl tmp.psl 
    liftUp -type=.psl stdout $srclift warn tmp.psl |
        liftUp -type=.psl -pslQ ${srcname}.${tgtname}.psl $tgtlift warn stdin 
    """
}


process blat{    
    tag "blat.${params.distance}.${srcname}.${tgtname}"
    label 'small'

    input: 
        tuple val(srcname), val(srcfile), val(tgtname), val(tgtfile) 
        file tgtlift 
        file srclift 
        file ooc11
        file ooc12

    output: 
        tuple val(srcname), val(tgtname), file("${srcname}.${tgtname}.psl"), emit: al_files_ch
  
    stub:
    """
    touch ${srcname}.${tgtname}.psl
    """

    script:
    """
    blat ${srcfile} ${tgtfile} ${params.custom} -ooc=${ooc12} -out=psl tmp.psl 
    liftUp -type=.psl stdout $srclift warn tmp.psl |
        liftUp -type=.psl -pslQ ${srcname}.${tgtname}.psl $tgtlift warn stdin 
    """
}
