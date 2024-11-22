/*
primates
Gap open penalty (O)	400
Gap extend penalty (E)	30
HSP threshold (K)	5000
Threshold for gapped extension (L)	5000
Threshold for alignments between gapped alignment blocks (H)	3000
Masking count (M)	10
Seed and Transition value (T)	1
Scoring matrix (Q)	
*/
/*
mouse
Gap open penalty (O)	400
Gap extend penalty (E)	30
HSP threshold (K)	3000
Threshold for gapped extension (L)	3000
Threshold for alignments between gapped alignment blocks (H)	2200
Masking count (M)	
Seed and Transition value (T)	1
Scoring matrix (Q)	

Default:
     A    C    G    T
    91 -114  -31 -123
  -114  100 -125  -31
   -31 -125  100 -114
  -123  -31 -114   91
*/
/*
chicken
penalty (O)	400
Gap extend penalty (E)	30
HSP threshold (K)	3000
Threshold for gapped extension (L)	3000
Threshold for alignments between gapped alignment blocks (H)	2200
Masking count (M)	
Seed and Transition value (T)	1
*/
process lastz{
    label 'medium'

    input: 
        tuple val(srcname), path(srcfile), val(tgtname), path(tgtfile), val(nseq) 
        path tgtlift 
        path srclift 

    output: 
        tuple val(srcname), val(tgtname), file("${srcname}.${tgtname}.psl"), emit: al_files_ch

    script:
    def qfile = params.qscores ? file(params.qscores) : file("${baseDir}/assets/general.q")
    def lastz_args = "E=30 H=2200 K=3000 L=3000 O=400 T=1 ‑‑allocate:traceback=2048.0M"
    def srcmultiple = nseq > 1 ? "[multiple]" : ""
    if (params.custom) {
        qfile = params.qscores ? file(params.qscores) : null
        lastz_args = params.custom
    } else if (params.distance == 'near'){
        qfile = params.qscores ? file(params.qscores) : file("${baseDir}/assets/human_chimp.v2.q")
        lastz_args = "B=0 C=0 E=150 H=0 K=4500 L=3000 M=254 O=600 T=2 Y=15000"
    } else if (params.distance == 'medium'){
        qfile = params.qscores ? file(params.qscores) : null
        lastz_args = "B=0 C=0 E=30 H=0 K=3000 L=3000 M=50 O=400 T=1 Y=9400"
    } else if (params.distance == 'far') {
        qfile = params.qscores ? file(params.qscores) : file("${baseDir}/assets/HoxD55.q")
        lastz_args = "B=0 C=0 E=30 H=2000 K=2200 L=6000 M=50 O=400 T=2 Y=3400"
    } else if (params.distance == 'primate') {
        lastz_args = "E=30 H=3000 K=5000 L=5000 M=10 O=400 T=1 ‑‑allocate:traceback=2048.0M"
        qfile = params.qscores ? file(params.qscores) : file("${projectDir}/assets/human_chimp.v2.q")
    } else if (params.distance == 'general') {
        qfile = params.qscores ? file(params.qscores) : file("${baseDir}/assets/general.q")
        lastz_args = "E=30 H=2200 K=3000 L=3000 O=400 T=1 ‑‑allocate:traceback=2048.0M"
    } else {
        log.info"""Preset ${params.distance} not available for lastz"""   
        log.info"""The software will use general instead."""   
        log.info"""If it is not ok for you, re-run selecting among the following options:"""   
        log.info""" 1 - near"""   
        log.info""" 2 - medium"""   
        log.info""" 3 - far"""   
        log.info""" 4 - primate"""   
        log.info""" 5 - general"""   
    }
    def qscores = qfile ? "Q=${qfile}" : ""
    """
    echo ${lastz_args}
    lastz ${srcfile}${srcmultiple} ${tgtfile} ${lastz_args} --ambiguous=iupac ${qscores} --format=lav |
        lavToPsl stdin stdout |
            liftUp -type=.psl stdout ${srclift} warn stdin |
                liftUp -type=.psl -pslQ ${srcname}.${tgtname}.psl $tgtlift warn stdin 
    """
  
    stub:
    """
    touch ${srcname}.${tgtname}.psl
    """
}



process lastz_primates{    
    tag "lastz_primates.${srcname}.${tgtname}"
    label 'medium'

    input: 
        tuple val(srcname), path(srcfile), val(tgtname), path(tgtfile), val(nseq) 
        path tgtlift 
        path srclift 

    output: 
        tuple val(srcname), val(tgtname), file("${srcname}.${tgtname}.psl"), emit: al_files_ch

    script:
    def qfile = params.qscores ? file(params.qscores) : file("${projectDir}/assets/human_chimp.v2.q")
    def qscores = "Q=${qfile}"
    def srcmultiple = nseq > 1 ? "[multiple]" : ""
    def lastz_args = "E=30 H=3000 K=5000 L=5000 M=10 O=400 T=1"
    """
    echo ${lastz_args}
    lastz ${srcfile}${srcmultiple} ${tgtfile} ${lastz_args} ‑‑allocate:traceback=2048.0M --ambiguous=iupac ${qscores} --format=lav |
        lavToPsl stdin stdout |
            liftUp -type=.psl stdout ${srclift} warn stdin |
                liftUp -type=.psl -pslQ ${srcname}.${tgtname}.psl ${tgtlift} warn stdin
    """
  
    stub:
    """
    touch ${srcname}.${tgtname}.psl
    """
}

process lastz_general{    
    tag "lastz_general.${srcname}.${tgtname}"
    label 'medium'

    input: 
        tuple val(srcname), path(srcfile), val(tgtname), path(tgtfile), val(nseq) 
        path tgtlift 
        path srclift 

    output: 
        tuple val(srcname), val(tgtname), file("${srcname}.${tgtname}.psl"), emit: al_files_ch

    script:
    def qfile = params.qscores ? file(params.qscores) : file("${baseDir}/assets/general.q")
    def qscores = "Q=${qfile}"
    def srcmultiple = nseq > 1 ? "[multiple]" : ""
    def lastz_args = "E=30 H=2200 K=3000 L=3000 O=400 T=1"
    """
    echo ${lastz_args}
    lastz ${srcfile}${srcmultiple} ${tgtfile} ${lastz_args} ‑‑allocate:traceback=2048.0M --ambiguous=iupac ${qscores} --format=lav |
        lavToPsl stdin stdout |
            liftUp -type=.psl stdout ${srclift} warn stdin |
                liftUp -type=.psl -pslQ ${srcname}.${tgtname}.psl ${tgtlift} warn stdin
    """
  
    stub:
    """
    touch ${srcname}.${tgtname}.psl
    """
}

process lastz_near{    
    tag "lastz_near.${srcname}.${tgtname}"
    label 'medium'

    input: 
        tuple val(srcname), path(srcfile), val(tgtname), path(tgtfile), val(nseq) 
        path tgtlift 
        path srclift 

    output: 
        tuple val(srcname), val(tgtname), file("${srcname}.${tgtname}.psl"), emit: al_files_ch

    script:
    def qfile = params.qscores ? file(params.qscores) : file("${baseDir}/assets/human_chimp.v2.q")
    def qscores = "Q=${qfile}"
    def srcmultiple = nseq > 1 ? "[multiple]" : "" 
    def lastz_args = "B=0 C=0 E=150 H=0 K=4500 L=3000 M=254 O=600 T=2 Y=15000"
    """
    echo ${lastz_args}
    lastz ${srcfile}${srcmultiple} ${tgtfile} ${lastz_args} --ambiguous=iupac ${qscores} --format=lav |
        lavToPsl stdin stdout |
            liftUp -type=.psl stdout ${srclift} warn stdin |
                liftUp -type=.psl -pslQ ${srcname}.${tgtname}.psl ${tgtlift} warn stdin 
    """
  
    stub:
    """
    touch ${srcname}.${tgtname}.psl
    """
}

process lastz_medium{    
    tag "lastz_med.${srcname}.${tgtname}"
    label 'medium'

    input: 
        tuple val(srcname), path(srcfile), val(tgtname), path(tgtfile), val(nseq) 
        path tgtlift 
        path srclift 

    output: 
        tuple val(srcname), val(tgtname), file("${srcname}.${tgtname}.psl"), emit: al_files_ch

    script:
    def qfile = params.qscores ? file(params.qscores) : null
    def qscores = qfile ? "Q=${qfile}" : ""
    def srcmultiple = nseq > 1 ? "[multiple]" : ""
    def lastz_args = "B=0 C=0 E=30 H=0 K=3000 L=3000 M=50 O=400 T=1 Y=9400"
    """
    echo ${lastz_args}
    lastz ${srcfile}${srcmultiple} ${tgtfile} ${lastz_args} ${qscores} --ambiguous=iupac --format=lav |
        lavToPsl stdin stdout |
            liftUp -type=.psl stdout ${srclift} warn stdin |
                liftUp -type=.psl -pslQ ${srcname}.${tgtname}.psl ${tgtlift} warn stdin 
    """
  
    stub:
    """
    touch ${srcname}.${tgtname}.psl
    """
}

process lastz_far{    
    tag "lastz_far.${srcname}.${tgtname}"
    label 'medium'

    input: 
        tuple val(srcname), path(srcfile), val(tgtname), path(tgtfile), val(nseq) 
        path tgtlift 
        path srclift 

    output: 
        tuple val(srcname), val(tgtname), file("${srcname}.${tgtname}.psl"), emit: al_files_ch

    script:
    def qfile = params.qscores ? file(params.qscores) : file("${baseDir}/assets/HoxD55.q")
    def qscores = "Q=${qfile}"
    def srcmultiple = nseq > 1 ? "[multiple]" : ""
    def lastz_args = "B=0 C=0 E=30 H=2000 K=2200 L=6000 M=50 O=400 T=2 Y=3400"
    """
    echo ${lastz_args}
    lastz ${srcfile}${srcmultiple} ${tgtfile} --ambiguous=iupac ${qscores} ${lastz_args} --format=lav |
        lavToPsl stdin stdout |
            liftUp -type=.psl stdout ${srclift} warn stdin |
                liftUp -type=.psl -pslQ ${srcname}.${tgtname}.psl ${tgtlift} warn stdin 
    """
  
    stub:
    """
    touch ${srcname}.${tgtname}.psl
    """
}

process lastz_custom{    
    tag "lastz_cust.${srcname}.${tgtname}"
    label 'medium'

    input: 
        tuple val(srcname), path(srcfile), val(tgtname), path(tgtfile), val(nseq) 
        path tgtlift 
        path srclift 

    output: 
        tuple val(srcname), val(tgtname), file("${srcname}.${tgtname}.psl"), emit: al_files_ch

    script:
    def qfile = params.qscores ? file(params.qscores) : null
    def qscores = qfile ? "Q=${qfile}" : ""
    def srcmultiple = nseq > 1 ? "[multiple]" : "" 
    """
    echo ${params.custom}
    lastz ${srcfile}${srcmultiple} ${tgtfile} ${params.custom} ${qscores} --ambiguous=iupac --format=lav |
        lavToPsl stdin stdout |
            liftUp -type=.psl stdout ${srclift} warn stdin |
                liftUp -type=.psl -pslQ ${srcname}.${tgtname}.psl $tgtlift warn stdin 
    """
  
    stub:
    """
    touch ${srcname}.${tgtname}.psl
    """
}
