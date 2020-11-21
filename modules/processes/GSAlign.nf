//Processes for hmmer alignments

process gsalign_same{    
    tag "gsalign_${params.distance}.${srcname}.${tgtname}"
    label 'small_multi'

    input: 
        tuple val(srcname), val(srcfile), val(tgtname), val(tgtfile) 
        file tgtlift 
        file srclift 

    output: 
        tuple val(srcname), val(tgtname), file("${srcname}.${tgtname}.psl"), emit: al_files_ch
  
    script:
    """
    GSAlign -r ${source} -q ${tgtfile} -sen -t ${task.cpus} -idy 98 -o ${srcname}.${tgtname}.tmp
    maf-convert psl ${srcname}.${tgtname}.tmp.maf |
        liftUp -type=.psl stdout $srclift warn stdin |
        liftUp -type=.psl -pslQ ${srcname}.${tgtname}.psl $tgtlift warn stdin && rm ${srcname}.${tgtname}.tmp.*
    """
}

process gsalign_near{    
    tag "gsalign_${params.distance}.${srcname}.${tgtname}"
    label 'small_multi'

    input: 
        tuple val(srcname), val(srcfile), val(tgtname), val(tgtfile) 
        file tgtlift 
        file srclift 

    output: 
        tuple val(srcname), val(tgtname), file("${srcname}.${tgtname}.psl"), emit: al_files_ch
  
    script:
    """
    GSAlign -r ${source} -q ${tgtfile} -sen -t ${task.cpus} -idy 95 -o ${srcname}.${tgtname}.tmp
    maf-convert psl ${srcname}.${tgtname}.tmp.maf |
        liftUp -type=.psl stdout $srclift warn stdin |
        liftUp -type=.psl -pslQ ${srcname}.${tgtname}.psl $tgtlift warn stdin && rm ${srcname}.${tgtname}.tmp.*
    """
}

process gsalign_medium{    
    tag "gsalign_${params.distance}.${srcname}.${tgtname}"
    label 'small_multi'

    input: 
        tuple val(srcname), val(srcfile), val(tgtname), val(tgtfile) 
        file tgtlift 
        file srclift 

    output: 
        tuple val(srcname), val(tgtname), file("${srcname}.${tgtname}.psl"), emit: al_files_ch
  
    script:
    """
    GSAlign -r ${source} -q ${tgtfile} -t ${task.cpus} -idy 90 -o ${srcname}.${tgtname}.tmp
    maf-convert psl ${srcname}.${tgtname}.tmp.maf |
        liftUp -type=.psl stdout $srclift warn stdin |
        liftUp -type=.psl -pslQ ${srcname}.${tgtname}.psl $tgtlift warn stdin && rm ${srcname}.${tgtname}.tmp.*
    """
}

process gsalign_far{    
    tag "gsalign_${params.distance}.${srcname}.${tgtname}"
    label 'small_multi'

    input: 
        tuple val(srcname), val(srcfile), val(tgtname), val(tgtfile) 
        file tgtlift 
        file srclift 

    output: 
        tuple val(srcname), val(tgtname), file("${srcname}.${tgtname}.psl"), emit: al_files_ch
  
    script:
    """
    GSAlign -r ${source} -q ${tgtfile} -t ${task.cpus} -idy 80 -o ${srcname}.${tgtname}.tmp
    maf-convert psl ${srcname}.${tgtname}.tmp.maf |
        liftUp -type=.psl stdout $srclift warn stdin |
        liftUp -type=.psl -pslQ ${srcname}.${tgtname}.psl $tgtlift warn stdin && rm ${srcname}.${tgtname}.tmp.*
    """
}

process gsalign_custom{    
    tag "gsalign_${params.distance}.${srcname}.${tgtname}"
    label 'small'

    input: 
        tuple val(srcname), val(srcfile), val(tgtname), val(tgtfile) 
        file tgtlift 
        file srclift 

    output: 
        tuple val(srcname), val(tgtname), file("${srcname}.${tgtname}.psl"), emit: al_files_ch
  
    script:
    """
    GSAlign -r ${source} -q ${tgtfile} -t ${task.cpus} ${params.custom} -o ${srcname}.${tgtname}.tmp
    maf-convert psl ${srcname}.${tgtname}.tmp.maf |
        liftUp -type=.psl stdout $srclift warn stdin |
        liftUp -type=.psl -pslQ ${srcname}.${tgtname}.psl $tgtlift warn stdin && rm ${srcname}.${tgtname}.tmp.*
    """
}