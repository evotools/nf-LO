//Processes for minimap2 alignments
process minimap2 {    
    tag "minimap2.${params.distance}.${srcname}.${tgtname}"
    label 'minimap2'

    input: 
        tuple val(srcname), path(srcfile), val(tgtname), path(tgtfile) 
        path tgtlift 
        path srclift 

    output: 
        tuple val(srcname), val(tgtname), file("${srcname}.${tgtname}.psl"), emit: al_files_ch

    script:
    def mm2_args = "-cx asm10"
    if (params.custom) {
        mm2_args = params.custom
    } else if (params.distance == 'near'){
        mm2_args = "-cx asm5"
    } else if (params.distance == 'medium'){
        mm2_args = "-cx asm10"
    } else if (params.distance == 'far') {
        mm2_args = "-cx asm20"
    } else {
        log.info"""Preset ${params.distance} not available for minimap2"""   
        log.info"""The software will use the medium instead."""   
        log.info"""If it is not ok for you, re-run selecting among the following options:"""   
        log.info""" 1 - near"""   
        log.info""" 2 - medium"""   
        log.info""" 3 - far"""   
    }
    """
    minimap2 -t ${task.cpus} ${mm2_args} --cap-kalloc 100m --cap-sw-mem 50m --cs=long ${srcfile} ${tgtfile} | 
        paftools.js view -f maf - |
        maf-convert psl - |
        liftUp -type=.psl stdout ${srclift} warn stdin |
        liftUp -type=.psl -pslQ ${srcname}.${tgtname}.psl ${tgtlift} warn stdin 
    """
  
    stub:
    """
    touch ${srcname}.${tgtname}.psl
    """
}
