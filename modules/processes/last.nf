//Processes for last alignments

chainNear="-minScore=5000 -linearGap=medium"
chainMedium="-minScore=3000 -linearGap=medium"
chainFar="-minScore=5000 -linearGap=loose"


process last_near{    
    tag "last_${params.distance}.${srcname}.${tgtname}"
    label 'medium'

    input: 
        tuple val(srcname), val(srcfile), val(tgtname), val(tgtfile) 
        path tgtlift 
        path srclift 
        path twoBitS
        path twoBitT

    output: 
        path "${srcname}.${tgtname}.chain"
  
    script:
    """
    lastdb -P0 -uNEAR -R01 localDB ${srcfile}
    lastal -m50 -E0.05 -C2 localDB ${tgtfile} | 
        maf-convert psl - |
        liftUp -type=.psl stdout $srclift warn stdin |
        liftUp -type=.psl -pslQ stdout $tgtlift warn stdin | 
        axtChain $chainNear -verbose=0 -psl stdin ${twoBitS} ${twoBitT} stdout | \
        chainAntiRepeat ${twoBitS} ${twoBitT} stdin stdout > ${srcname}.${tgtname}.chain \
        && rm localDB.*
    """
}


process last_medium{    
    tag "last_${params.distance}.${srcname}.${tgtname}"
    label 'medium'

    input: 
        tuple val(srcname), val(srcfile), val(tgtname), val(tgtfile) 
        path tgtlift 
        path srclift 
        path twoBitS
        path twoBitT

    output: 
        path "${srcname}.${tgtname}.chain"
  
    script:
    """
    lastdb -P0 -uMAM8 -R01 localDB ${srcfile}
    lastal -m75 -E0.05 -C2 localDB ${tgtfile} | 
        maf-convert psl - |
        liftUp -type=.psl stdout $srclift warn stdin |
        liftUp -type=.psl -pslQ stdout $tgtlift warn stdin | 
        axtChain $chainMedium -verbose=0 -psl stdin ${twoBitS} ${twoBitT} stdout | \
        chainAntiRepeat ${twoBitS} ${twoBitT} stdin stdout > ${srcname}.${tgtname}.chain \
        && rm localDB.*
    """
}


process last_far{    
    tag "last_${params.distance}.${srcname}.${tgtname}"
    label 'medium'

    input: 
        tuple val(srcname), val(srcfile), val(tgtname), val(tgtfile) 
        path tgtlift 
        path srclift 
        path twoBitS
        path twoBitT

    output: 
        path "${srcname}.${tgtname}.chain"
  
    script:
    """
    lastdb -P0 -uMAM4 -R01 localDB ${srcfile}
    lastal -m100 -E0.05 -C2 localDB ${tgtfile} | 
        maf-convert psl - |
        liftUp -type=.psl stdout $srclift warn stdin |
        liftUp -type=.psl -pslQ stdout $tgtlift warn stdin | 
        axtChain $chainFar -verbose=0 -psl stdin ${twoBitS} ${twoBitT} stdout | \
        chainAntiRepeat ${twoBitS} ${twoBitT} stdin stdout > ${srcname}.${tgtname}.chain \
        && rm localDB.*
    """
}


process last_custom{    
    tag "last_${params.distance}.${srcname}.${tgtname}"
    label 'medium'

    input: 
        tuple val(srcname), val(srcfile), val(tgtname), val(tgtfile) 
        path tgtlift 
        path srclift 
        path twoBitS
        path twoBitT

    output: 
        path "${srcname}.${tgtname}.chain"
  
    script:
    """
    lastdb -P0 -uMAM8 -R01 localDB ${srcfile}
    lastal ${params.custom} localDB ${tgtfile} | 
        maf-convert psl - |
        liftUp -type=.psl stdout $srclift warn stdin |
        liftUp -type=.psl -pslQ stdout $tgtlift warn stdin | 
        axtChain $params.customChain -verbose=0 -psl stdin ${twoBitS} ${twoBitT} stdout | \
        chainAntiRepeat ${twoBitS} ${twoBitT} stdin stdout > ${srcname}.${tgtname}.chain \
        && rm localDB.*
    """
}

// Old last version
/*
process last{    
    tag "last_${params.distance}.${srcname}.${tgtname}"

    input: 
        tuple val(srcname), val(srcfile), val(tgtname), val(tgtfile) 
        file tgtlift 
        file srclift 

    output: 
        tuple val(srcname), val(tgtname), file("${srcname}.${tgtname}.psl"), emit: al_files_ch
  
    script:
    if( params.distance == 'near' )
        """
        lastdb -P0 -uNEAR -R01 localDB ${srcfile}
        lastal -m50 -E0.05 -C2 localDB ${tgtfile} | 
            maf-convert psl - |
            liftUp -type=.psl stdout $srclift warn stdin |
            liftUp -type=.psl -pslQ ${srcname}.${tgtname}.psl $tgtlift warn stdin && rm localDB.*
        """
    else if ( params.distance == 'medium' )
        """
        lastdb -P0 -uMAM8 -R01 localDB ${srcfile}
        lastal -m75 -E0.05 -C2 localDB ${tgtfile} | 
            maf-convert psl - |
            liftUp -type=.psl stdout $srclift warn stdin |
            liftUp -type=.psl -pslQ ${srcname}.${tgtname}.psl $tgtlift warn stdin && rm localDB.*
        """
    else if ( params.distance == 'far' )
        """
        lastdb -P0 -uMAM4 -R01 localDB ${srcfile}
        lastal -m100 -E0.05 -C2 localDB ${tgtfile} | 
            maf-convert psl - |
            liftUp -type=.psl stdout $srclift warn stdin |
            liftUp -type=.psl -pslQ ${srcname}.${tgtname}.psl $tgtlift warn stdin && rm localDB.*
        """
    else
        """
        lastdb -P0 -uMAM8 -R01 localDB ${srcfile}
        lastal ${params.custom} localDB ${tgtfile} | 
            maf-convert psl - |
            liftUp -type=.psl stdout $srclift warn stdin |
            liftUp -type=.psl -pslQ ${srcname}.${tgtname}.psl $tgtlift warn stdin && rm localDB.*
        """
}
*/