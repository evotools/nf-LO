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
        tuple val(srcname), val(tgtname), file("${srcname}.${tgtname}.paf.gz"), emit: paf_files_ch

    script:
    def mm2_args = "-cx asm10"
    if (params.custom && params.distance == "custom") {
        mm2_args = params.custom
    } else if (params.distance == 'near'){
        mm2_args = "-cx asm5"
    } else if (params.distance == 'medium'){
        mm2_args = "-cx asm10"
    } else if (params.distance == 'far') {
        mm2_args = "-cx asm20"
    } else {
        mm2_args = "-cx asm10"
    }
    """
    minimap2 -t ${task.cpus} ${mm2_args} --cs=long ${srcfile} ${tgtfile} | gzip -c > ${srcname}.${tgtname}.paf.gz
    paftools.js view -f maf ${srcname}.${tgtname}.paf.gz |
        maf-convert psl - |
        liftUp -type=.psl stdout ${srclift} warn stdin |
        liftUp -type=.psl -pslQ ${srcname}.${tgtname}.psl ${tgtlift} warn stdin 
    """
  
    stub:
    """
    touch ${srcname}.${tgtname}.psl
    """
}
