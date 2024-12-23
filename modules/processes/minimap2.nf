//Processes for minimap2 alignments
minimap2Near="-cx asm5"
minimap2Medium="-cx asm10"
minimap2Far="-cx asm20"

process minimap2_near{    
    tag "minimap2.${params.distance}.${srcname}.${tgtname}"
    label 'minimap2'

    input: 
        tuple val(srcname), path(srcfile), val(tgtname), path(tgtfile) 
        path tgtlift 
        path srclift 

    output: 
        tuple val(srcname), val(tgtname), file("${srcname}.${tgtname}.psl"), emit: al_files_ch
  
    stub:
    """
    touch ${srcname}.${tgtname}.psl
    """

    script:
    """
    minimap2 -t ${task.cpus} ${minimap2Near} --cap-kalloc 100m --cap-sw-mem 50m --cs=long ${srcfile} ${tgtfile} | 
        paftools.js view -f maf - |
        maf-convert psl - |
        liftUp -type=.psl stdout $srclift warn stdin |
        liftUp -type=.psl -pslQ ${srcname}.${tgtname}.psl $tgtlift warn stdin 
    """
}

process minimap2_medium{
    tag "minimap2.${params.distance}.${srcname}.${tgtname}"
    label 'minimap2'

    input: 
        tuple val(srcname), path(srcfile), val(tgtname), path(tgtfile) 
        path tgtlift 
        path srclift 

    output: 
        tuple val(srcname), val(tgtname), file("${srcname}.${tgtname}.psl"), emit: al_files_ch
  
    stub:
    """
    touch ${srcname}.${tgtname}.psl
    """

    script:
    """
    minimap2 -t ${task.cpus} --cap-kalloc 100m --cap-sw-mem 50m --cs=long ${minimap2Medium} ${srcfile} ${tgtfile} | 
        paftools.js view -f maf - |
        maf-convert psl - |
        liftUp -type=.psl stdout $srclift warn stdin |
        liftUp -type=.psl -pslQ ${srcname}.${tgtname}.psl $tgtlift warn stdin 
    """
}

process minimap2_far{
    tag "minimap2.${params.distance}.${srcname}.${tgtname}"
    label 'minimap2'

    input: 
        tuple val(srcname), path(srcfile), val(tgtname), path(tgtfile) 
        path tgtlift 
        path srclift 

    output: 
        tuple val(srcname), val(tgtname), file("${srcname}.${tgtname}.psl"), emit: al_files_ch
  
    stub:
    """
    touch ${srcname}.${tgtname}.psl
    """

    script:
    """
    minimap2 -t ${task.cpus} --cap-kalloc 100m --cap-sw-mem 50m --cs=long ${minimap2Far} ${srcfile} ${tgtfile} | 
        paftools.js view -f maf - |
        maf-convert psl - |
        liftUp -type=.psl stdout $srclift warn stdin |
        liftUp -type=.psl -pslQ ${srcname}.${tgtname}.psl $tgtlift warn stdin 
    """
}

process minimap2_custom{    
    tag "minimap2.${params.distance}.${srcname}.${tgtname}"
    label 'minimap2'

    input: 
        tuple val(srcname), path(srcfile), val(tgtname), path(tgtfile) 
        path tgtlift 
        path srclift 

    output: 
        tuple val(srcname), val(tgtname), file("${srcname}.${tgtname}.psl"), emit: al_files_ch
  
    stub:
    """
    touch ${srcname}.${tgtname}.psl
    """

    script:
    """
    minimap2 -t ${task.cpus} --cap-kalloc 100m --cap-sw-mem 50m --cs=long ${params.custom} ${srcfile} ${tgtfile} | 
        paftools.js view -f maf - |
        maf-convert psl - |
        liftUp -type=.psl stdout $srclift warn stdin |
        liftUp -type=.psl -pslQ ${srcname}.${tgtname}.psl $tgtlift warn stdin 
    """
}
