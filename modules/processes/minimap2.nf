//Processes for minimap2 alignments
minimap2Near="-cx asm5"
minimap2Medium="-cx asm10"
minimap2Far="-cx asm20"

process minimap2_near{    
    tag "minimap2.${params.distance}.${srcname}.${tgtname}"
    label 'small_multi'

    input: 
        tuple val(srcname), val(srcfile), val(tgtname), val(tgtfile) 
        file tgtlift 
        file srclift 

    output: 
        tuple val(srcname), val(tgtname), file("${srcname}.${tgtname}.psl"), emit: al_files_ch
  
    script:
    """
    minimap2 -t ${task.cpus} ${minimap2Near} --cs=long ${srcfile} ${tgtfile} | 
        paftools.js view -f maf - |
        maf-convert psl - |
        liftUp -type=.psl stdout $srclift warn stdin |
        liftUp -type=.psl -pslQ ${srcname}.${tgtname}.psl $tgtlift warn stdin 
    """
}
process minimap2_medium{
    tag "minimap2.${params.distance}.${srcname}.${tgtname}"
    label 'small_multi'

    input: 
        tuple val(srcname), val(srcfile), val(tgtname), val(tgtfile) 
        file tgtlift 
        file srclift 

    output: 
        tuple val(srcname), val(tgtname), file("${srcname}.${tgtname}.psl"), emit: al_files_ch
  
    script:
    """
    minimap2 -t ${task.cpus} --cs=long ${minimap2Medium} ${srcfile} ${tgtfile} | 
        paftools.js view -f maf - |
        maf-convert psl - |
        liftUp -type=.psl stdout $srclift warn stdin |
        liftUp -type=.psl -pslQ ${srcname}.${tgtname}.psl $tgtlift warn stdin 
    """
}

process minimap2_far{
    tag "minimap2.${params.distance}.${srcname}.${tgtname}"
    label 'small_multi'

    input: 
        tuple val(srcname), val(srcfile), val(tgtname), val(tgtfile) 
        file tgtlift 
        file srclift 

    output: 
        tuple val(srcname), val(tgtname), file("${srcname}.${tgtname}.psl"), emit: al_files_ch
  
    script:
    """
    minimap2 -t ${task.cpus} --cs=long ${minimap2Far} ${srcfile} ${tgtfile} | 
        paftools.js view -f maf - |
        maf-convert psl - |
        liftUp -type=.psl stdout $srclift warn stdin |
        liftUp -type=.psl -pslQ ${srcname}.${tgtname}.psl $tgtlift warn stdin 
    """
}

process minimap2_custom{    
    tag "minimap2.${params.distance}.${srcname}.${tgtname}"
    label 'small_multi'

    input: 
        tuple val(srcname), val(srcfile), val(tgtname), val(tgtfile) 
        file tgtlift 
        file srclift 

    output: 
        tuple val(srcname), val(tgtname), file("${srcname}.${tgtname}.psl"), emit: al_files_ch
  
    script:
    """
    minimap2 -t ${task.cpus} --cs=long ${params.custom} ${srcfile} ${tgtfile} | 
        paftools.js view -f maf - |
        maf-convert psl - |
        liftUp -type=.psl stdout $srclift warn stdin |
        liftUp -type=.psl -pslQ ${srcname}.${tgtname}.psl $tgtlift warn stdin 
    """
}

/*
process minimap2{    
    tag "minimap2.${params.distance}.${srcname}.${tgtname}"

    input: 
        tuple val(srcname), val(srcfile), val(tgtname), val(tgtfile) 
        file tgtlift 
        file srclift 

    output: 
        tuple val(srcname), val(tgtname), file("${srcname}.${tgtname}.psl"), emit: al_files_ch
  
    script:
    if( params.distance == 'near' )
        """
        minimap2 -t ${task.cpus} ${minimap2Near} --cs=long ${srcfile} ${tgtfile} | 
            paftools.js view -f maf - |
            maf-convert psl - |
            liftUp -type=.psl stdout $srclift warn stdin |
            liftUp -type=.psl -pslQ ${srcname}.${tgtname}.psl $tgtlift warn stdin 
        """
    else if( params.distance == 'medium' )
        """
        minimap2 -t ${task.cpus} --cs=long ${minimap2Medium} ${srcfile} ${tgtfile} | 
            paftools.js view -f maf - |
            maf-convert psl - |
            liftUp -type=.psl stdout $srclift warn stdin |
            liftUp -type=.psl -pslQ ${srcname}.${tgtname}.psl $tgtlift warn stdin 
        """
    else if( params.distance == 'far' )
        """
        minimap2 -t ${task.cpus} --cs=long ${minimap2Far} ${srcfile} ${tgtfile} | 
            paftools.js view -f maf - |
            maf-convert psl - |
            liftUp -type=.psl stdout $srclift warn stdin |
            liftUp -type=.psl -pslQ ${srcname}.${tgtname}.psl $tgtlift warn stdin 
        """
    else if( params.distance == 'custom' )
        """
        minimap2 -t ${task.cpus} --cs=long ${params.custom} ${srcfile} ${tgtfile} | 
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
*/