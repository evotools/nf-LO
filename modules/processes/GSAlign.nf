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
    bwt_index ${srcfile} ${srcname} && chmod a+rw ${srcname}.*
    GSAlign -i ${srcname} -q ${tgtfile} -sen -t ${task.cpus} -idy 90 -no_vcf -o ${srcname}.${tgtname}.tmp
    if [ -e ${srcname}.${tgtname}.tmp.maf ]; then
        sed 's/ref.//g' ${srcname}.${tgtname}.tmp.maf | 
            sed 's/qry.//g' |
            maf-convert psl - |
            liftUp -type=.psl stdout $srclift warn stdin |
            liftUp -type=.psl -pslQ ${srcname}.${tgtname}.psl $tgtlift warn stdin && rm ${srcname}.${tgtname}.tmp.*
    else
        echo "##maf version=1 " | 
            liftUp -type=.psl stdout $srclift warn stdin |
            liftUp -type=.psl -pslQ ${srcname}.${tgtname}.psl $tgtlift warn stdin 
    fi
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
    bwt_index ${srcfile} ${srcname} && chmod a+rw ${srcname}.*
    GSAlign -i ${srcname} -q ${tgtfile} -sen -t ${task.cpus} -idy 80 -no_vcf -o ${srcname}.${tgtname}.tmp
    if [ -e ${srcname}.${tgtname}.tmp.maf ]; then
        sed 's/ref.//g' ${srcname}.${tgtname}.tmp.maf | 
            sed 's/qry.//g' |
            maf-convert psl - |
            liftUp -type=.psl stdout $srclift warn stdin |
            liftUp -type=.psl -pslQ ${srcname}.${tgtname}.psl $tgtlift warn stdin && rm ${srcname}.${tgtname}.tmp.*
    else
        echo "##maf version=1 " | 
            liftUp -type=.psl stdout $srclift warn stdin |
            liftUp -type=.psl -pslQ ${srcname}.${tgtname}.psl $tgtlift warn stdin 
    fi
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
    bwt_index ${srcfile} ${srcname} && chmod a+rw ${srcname}.*
    GSAlign -i ${srcname} -q ${tgtfile} -t ${task.cpus} -idy 75 -no_vcf -o ${srcname}.${tgtname}.tmp
    if [ -e ${srcname}.${tgtname}.tmp.maf ]; then
        sed 's/ref.//g' ${srcname}.${tgtname}.tmp.maf | 
            sed 's/qry.//g' |
            maf-convert psl - |
            liftUp -type=.psl stdout $srclift warn stdin |
            liftUp -type=.psl -pslQ ${srcname}.${tgtname}.psl $tgtlift warn stdin && rm ${srcname}.${tgtname}.tmp.*
    else
        echo "##maf version=1 " | 
            liftUp -type=.psl stdout $srclift warn stdin |
            liftUp -type=.psl -pslQ ${srcname}.${tgtname}.psl $tgtlift warn stdin 
    fi
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
    bwt_index ${srcfile} ${srcname} && chmod a+rw ${srcname}.*
    GSAlign -i ${srcname} -q ${tgtfile} -t ${task.cpus} -idy 70 -no_vcf -o ${srcname}.${tgtname}.tmp
    if [ -e ${srcname}.${tgtname}.tmp.maf ]; then
        sed 's/ref.//g' ${srcname}.${tgtname}.tmp.maf | 
            sed 's/qry.//g' |
            maf-convert psl - |
            liftUp -type=.psl stdout $srclift warn stdin |
            liftUp -type=.psl -pslQ ${srcname}.${tgtname}.psl $tgtlift warn stdin && rm ${srcname}.${tgtname}.tmp.*
    else
        echo "##maf version=1 " | 
            liftUp -type=.psl stdout $srclift warn stdin |
            liftUp -type=.psl -pslQ ${srcname}.${tgtname}.psl $tgtlift warn stdin
    fi
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
    bwt_index ${srcfile} ${srcname} && chmod a+rw ${srcname}.*
    GSAlign -i ${srcname} -q ${tgtfile} -t ${task.cpus} ${params.custom} -no_vcf -o ${srcname}.${tgtname}.tmp
    if [ -e ${srcname}.${tgtname}.tmp.maf ]; then
        sed 's/ref.//g' ${srcname}.${tgtname}.tmp.maf | 
            sed 's/qry.//g' |
            maf-convert psl - |
            liftUp -type=.psl stdout $srclift warn stdin |
            liftUp -type=.psl -pslQ ${srcname}.${tgtname}.psl $tgtlift warn stdin && rm ${srcname}.${tgtname}.tmp.*
    else
        echo "##maf version=1 " | 
            liftUp -type=.psl stdout $srclift warn stdin |
            liftUp -type=.psl -pslQ ${srcname}.${tgtname}.psl $tgtlift warn stdin
    fi
    """
}