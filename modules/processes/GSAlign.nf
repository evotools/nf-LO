//Processes for hmmer alignments

process gsalign{    
    tag "gsalign_${params.distance}.${srcname}.${tgtname}"
    label 'gsalign'

    input: 
        tuple val(srcname), path(srcfile), val(tgtname), path(tgtfile) 
        path tgtlift 
        path srclift 
        path index

    output: 
        tuple val(srcname), val(tgtname), file("${srcname}.${tgtname}.psl"), emit: al_files_ch

    script:
    def command = ""
    if (params.custom) {
        command = "GSAlign -i ${srcname} -q ${tgtfile} -t ${task.cpus} ${params.custom} -no_vcf -o ${srcname}.${tgtname}.tmp"
    } else if (params.distance == 'near'){
        command = "GSAlign -i ${srcname} -q ${tgtfile} -sen -t ${task.cpus} -idy 80 -no_vcf -o ${srcname}.${tgtname}.tmp"
    } else if (params.distance == 'medium'){
        command = "GSAlign -i ${srcname} -q ${tgtfile} -sen -t ${task.cpus} -idy 75 -no_vcf -o ${srcname}.${tgtname}.tmp"
    } else if (params.distance == 'far') {
        command = "GSAlign -i ${srcname} -q ${tgtfile} -sen -t ${task.cpus} -idy 70 -no_vcf -o ${srcname}.${tgtname}.tmp"
    } else if (params.distance == 'same') {
        command = "GSAlign -i ${srcname} -q ${tgtfile} -sen -t ${task.cpus} -no_vcf -o ${srcname}.${tgtname}.tmp"
    } else {
        command = "GSAlign -i ${srcname} -q ${tgtfile} -sen -t ${task.cpus} -no_vcf -o ${srcname}.${tgtname}.tmp"
        log.info"""Preset ${params.distance} not available for GSAlign"""   
        log.info"""The software will use the same instead."""   
        log.info"""If it is not ok for you, re-run selecting among the following options:"""   
        log.info""" 1 - near"""   
        log.info""" 2 - medium"""   
        log.info""" 3 - far"""   
        log.info""" 4 - same"""   
    }
    """
    ${command}
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
  
    stub:
    """
    touch ${srcname}.${tgtname}.psl
    """
}

process gsalign_same{    
    tag "gsalign_${params.distance}.${srcname}.${tgtname}"
    label 'gsalign'

    input: 
        tuple val(srcname), path(srcfile), val(tgtname), path(tgtfile) 
        path tgtlift 
        path srclift 
        path index

    output: 
        tuple val(srcname), val(tgtname), file("${srcname}.${tgtname}.psl"), emit: al_files_ch

    script:
    """
    GSAlign -i ${srcname} -q ${tgtfile} -sen -t ${task.cpus} -no_vcf -o ${srcname}.${tgtname}.tmp
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
  
    stub:
    """
    touch ${srcname}.${tgtname}.psl
    """
}

process gsalign_near{    
    tag "gsalign_${params.distance}.${srcname}.${tgtname}"
    label 'gsalign'

    input: 
        tuple val(srcname), path(srcfile), val(tgtname), path(tgtfile) 
        path tgtlift 
        path srclift 
        path index

    output: 
        tuple val(srcname), val(tgtname), file("${srcname}.${tgtname}.psl"), emit: al_files_ch

    script:
    """
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
  
    stub:
    """
    touch ${srcname}.${tgtname}.psl
    """
}

process gsalign_medium{    
    tag "gsalign_${params.distance}.${srcname}.${tgtname}"
    label 'gsalign'

    input: 
        tuple val(srcname), path(srcfile), val(tgtname), path(tgtfile) 
        path tgtlift 
        path srclift 
        path index

    output: 
        tuple val(srcname), val(tgtname), file("${srcname}.${tgtname}.psl"), emit: al_files_ch

    script:
    """
    GSAlign -i ${srcname} -q ${tgtfile} -sen -t ${task.cpus} -idy 75 -no_vcf -o ${srcname}.${tgtname}.tmp
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
  
    stub:
    """
    touch ${srcname}.${tgtname}.psl
    """
}

process gsalign_far{    
    tag "gsalign_${params.distance}.${srcname}.${tgtname}"
    label 'gsalign'

    input: 
        tuple val(srcname), path(srcfile), val(tgtname), path(tgtfile) 
        path tgtlift 
        path srclift 
        path index

    output: 
        tuple val(srcname), val(tgtname), file("${srcname}.${tgtname}.psl"), emit: al_files_ch

    script:
    """
    GSAlign -i ${srcname} -q ${tgtfile} -sen -t ${task.cpus} -idy 70 -no_vcf -o ${srcname}.${tgtname}.tmp
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
  
    stub:
    """
    touch ${srcname}.${tgtname}.psl
    """
}

process gsalign_custom{    
    tag "gsalign_${params.distance}.${srcname}.${tgtname}"
    label 'gsalign'

    input: 
        tuple val(srcname), path(srcfile), val(tgtname), path(tgtfile) 
        path tgtlift 
        path srclift 
        path index

    output: 
        tuple val(srcname), val(tgtname), file("${srcname}.${tgtname}.psl"), emit: al_files_ch

    script:
    """
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
  
    stub:
    """
    touch ${srcname}.${tgtname}.psl
    """
}


process bwt_index{    
    tag "bwt_index"
    label 'small'

    input: 
        tuple val(srcname), path(srcfile), val(tgtname), path(tgtfile) 

    output: 
        path "${srcname}.*"

    script:
    """
    bwt_index ${srcfile} ${srcname} && chmod a+rw ${srcname}.*
    """
  
    stub:
    """
    touch ${srcname}.pac
    touch ${srcname}.sa
    touch ${srcname}.amb
    touch ${srcname}.ann
    touch ${srcname}.bwt
    """
}
