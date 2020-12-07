//Processes for last alignments

chainNear="-minScore=5000 -linearGap=medium"
chainMedium="-minScore=3000 -linearGap=medium"
chainFar="-minScore=5000 -linearGap=loose"
if ( params.distance == "near" ){
    lastDB_param='-P0 -uNEAR -R01'
} else if ( params.distance == "medium" ) {
    lastDB_param='-P0 -uMAM8 -R01'
} else if ( params.distance == "far" ){
    lastDB_param='-P0 -uMAM4 -R01'
} else {
    lastDB_param='-P0 -uMAM8 -R01'
}


process last_near{    
    tag "last_${params.distance}.${srcname}.${tgtname}"
    label 'medium'

    input: 
        tuple val(srcname), val(srcfile), val(tgtname), val(tgtfile) 
        path tgtlift 
        path srclift 
        path twoBitS
        path twoBitT
        path localDB
        path training

    output: 
        path "${srcname}.${tgtname}.chain"
  
    script:
    """
    lastal -m50 -E0.05 -C2 -p ${training} localDB ${tgtfile} | 
        last-split -m 1 - |
        last-postmask - |
        maf-convert psl - |
        liftUp -type=.psl stdout $srclift warn stdin |
        liftUp -type=.psl -pslQ stdout $tgtlift warn stdin | 
        axtChain $chainNear -verbose=0 -psl stdin ${twoBitS} ${twoBitT} stdout | 
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
        path localDB
        path training

    output: 
        path "${srcname}.${tgtname}.chain"
  
    script:
    """
    lastal -m75 -E0.05 -C2 -p ${training} localDB ${tgtfile} | 
        last-split -m 1 - |
        last-postmask - |
        maf-convert psl - |
        liftUp -type=.psl stdout $srclift warn stdin |
        liftUp -type=.psl -pslQ stdout $tgtlift warn stdin | 
        axtChain $chainMedium -verbose=0 -psl stdin ${twoBitS} ${twoBitT} stdout | 
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
        path localDB
        path training

    output: 
        path "${srcname}.${tgtname}.chain"
  
    script:
    """
    lastal -m100 -E0.05 -C2 -p ${training} localDB ${tgtfile} | 
        last-split -m 1 - |
        last-postmask - |
        maf-convert psl - |
        liftUp -type=.psl stdout $srclift warn stdin |
        liftUp -type=.psl -pslQ stdout $tgtlift warn stdin | 
        axtChain $chainFar -verbose=0 -psl stdin ${twoBitS} ${twoBitT} stdout | 
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
        path localDB
        path training

    output: 
        path "${srcname}.${tgtname}.chain"
  
    script:
    """
    lastal ${params.custom} -p ${training} localDB ${tgtfile} | 
        last-split -m 1 - |
        last-postmask - |
        maf-convert psl - |
        liftUp -type=.psl stdout $srclift warn stdin |
        liftUp -type=.psl -pslQ stdout $tgtlift warn stdin | 
        axtChain $params.chainCustom -verbose=0 -psl stdin ${twoBitS} ${twoBitT} stdout | 
        chainAntiRepeat ${twoBitS} ${twoBitT} stdin stdout > ${srcname}.${tgtname}.chain \
        && rm localDB.*
    """
}

// Module to generate the DB
process make_db{    
    tag "makedb"
    label 'medium'

    input: 
        tuple val(srcname), val(srcfile), val(tgtname), val(tgtfile) 

    output: 
        path "localDB*"
  
    script:
    """
    lastdb ${lastDB_param} localDB ${srcfile}
    """
}

process last_train {
    tag "last_train"
    label "small"

    input: 
    path lastDB
    path tgt

    output:
    path "training.mat"

    output:
    """
    last-train -P0 --revsym --matsym --gapsym -E0.05 -C2 localDB ${tgt} > training.mat
    """
}