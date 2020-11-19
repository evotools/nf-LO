
lastzNear="B=0 C=0 E=150 H=0 K=4500 L=3000 M=254 O=600 T=2 Y=15000"
lastzMedium="B=0 C=0 E=30 H=0 K=3000 L=3000 M=50 O=400 T=1 Y=9400"
lastzFar="B=0 C=0 E=30 H=2000 K=2200 L=6000 M=50 O=400 T=2 Y=3400"

process lastz_near{    
    tag "lastz_near.${srcname}.${tgtname}"
    label 'small'

    input: 
        tuple val(srcname), val(srcfile), val(tgtname), val(tgtfile) 
        path tgtlift 
        path srclift 

    output: 
        tuple val(srcname), val(tgtname), file("${srcname}.${tgtname}.psl"), emit: al_files_ch
  
    script:
    """
    echo $lastzNear
    echo "A C G T" > human_chimp.v2.q
    echo "90 -330 -236 -356" >> human_chimp.v2.q
    echo "-330 100 -318 -236" >> human_chimp.v2.q
    echo "-236 -318 100 -330" >> human_chimp.v2.q
    echo "-356 -236 -330 90" >> human_chimp.v2.q
    lastz ${srcfile} ${tgtfile} ${lastzNear} Q=./human_chimp.v2.q --format=lav |
        lavToPsl stdin stdout |
            liftUp -type=.psl stdout $srclift warn stdin |
                liftUp -type=.psl -pslQ ${srcname}.${tgtname}.psl $tgtlift warn stdin && rm ./human_chimp.v2.q
    """
}

process lastz_medium{    
    tag "lastz_med.${srcname}.${tgtname}"
    label 'small'

    input: 
        tuple val(srcname), val(srcfile), val(tgtname), val(tgtfile) 
        path tgtlift 
        path srclift 

    output: 
        tuple val(srcname), val(tgtname), file("${srcname}.${tgtname}.psl"), emit: al_files_ch
  
    script:
    """
    echo $lastzMedium
    lastz ${srcfile} ${tgtfile} ${lastzMedium} --format=lav |
        lavToPsl stdin stdout |
            liftUp -type=.psl stdout $srclift warn stdin |
                liftUp -type=.psl -pslQ ${srcname}.${tgtname}.psl $tgtlift warn stdin 
    """
}

process lastz_far{    
    tag "lastz_far.${srcname}.${tgtname}"
    label 'small'

    input: 
        tuple val(srcname), val(srcfile), val(tgtname), val(tgtfile) 
        path tgtlift 
        path srclift 

    output: 
        tuple val(srcname), val(tgtname), file("${srcname}.${tgtname}.psl"), emit: al_files_ch
  
    script:
    """
    echo $lastzFar
    echo "A C G T" > HoxD55.q
    echo "91 -90 -25 -100" >> HoxD55.q
    echo "-90 100 -100 -25" >> HoxD55.q
    echo "-25 -100 100 -90" >> HoxD55.q
    echo "-100 -25 -90 91" >> HoxD55.q
    lastz ${srcfile} ${tgtfile} Q=./HoxD55.q ${lastzFar} --format=lav |
        lavToPsl stdin stdout |
            liftUp -type=.psl stdout $srclift warn stdin |
                liftUp -type=.psl -pslQ ${srcname}.${tgtname}.psl $tgtlift warn stdin && rm ./HoxD55.q
    """
}

process lastz_custom{    
    tag "lastz_cust.${srcname}.${tgtname}"
    label 'small'

    input: 
        tuple val(srcname), val(srcfile), val(tgtname), val(tgtfile) 
        path tgtlift 
        path srclift 

    output: 
        tuple val(srcname), val(tgtname), file("${srcname}.${tgtname}.psl"), emit: al_files_ch
  
    script:

    """
    echo ${params.custom}
    lastz ${srcfile} ${tgtfile} ${params.custom} --format=lav |
        lavToPsl stdin stdout |
            liftUp -type=.psl stdout $srclift warn stdin |
                liftUp -type=.psl -pslQ ${srcname}.${tgtname}.psl $tgtlift warn stdin 
    """
}

// Old version from nf-LO DSL1
/*
process lastz {
    tag "lastz_${params.distance}.${srcname}.${tgtname}"

    input: 
        tuple val(srcname), val(srcfile), val(tgtname), val(tgtfile) 
        file tgtlift 
        file srclift 

    output: 
        tuple val(srcname), val(tgtname), file("${srcname}.${tgtname}.psl"), emit: al_files_ch
  
    script:
    if( params.distance == 'near')
        """
        echo $lastzNear
        echo "A C G T" > human_chimp.v2.q
        echo "90 -330 -236 -356" >> human_chimp.v2.q
        echo "-330 100 -318 -236" >> human_chimp.v2.q
        echo "-236 -318 100 -330" >> human_chimp.v2.q
        echo "-356 -236 -330 90" >> human_chimp.v2.q
        lastz ${srcfile} ${tgtfile} ${lastzNear} Q=./human_chimp.v2.q --format=lav |
            lavToPsl stdin stdout |
                liftUp -type=.psl stdout $srclift warn stdin |
                    liftUp -type=.psl -pslQ ${srcname}.${tgtname}.psl $tgtlift warn stdin && rm ./human_chimp.v2.q
        """
    else if( params.distance == 'medium')
        """
        lastz ${srcfile} ${tgtfile} ${lastzMedium} --format=lav |
            lavToPsl stdin stdout |
                liftUp -type=.psl stdout $srclift warn stdin |
                    liftUp -type=.psl -pslQ ${srcname}.${tgtname}.psl $tgtlift warn stdin 
        """
    else if( params.distance == 'far')
        """
        echo $lastzFar
        echo "A C G T" > HoxD55.q
        echo "91 -90 -25 -100" >> HoxD55.q
        echo "-90 100 -100 -25" >> HoxD55.q
        echo "-25 -100 100 -90" >> HoxD55.q
        echo "-100 -25 -90 91" >> HoxD55.q
        lastz ${srcfile} ${tgtfile} Q=./HoxD55.q ${lastzFar} --format=lav |
            lavToPsl stdin stdout |
                liftUp -type=.psl stdout $srclift warn stdin |
                    liftUp -type=.psl -pslQ ${srcname}.${tgtname}.psl $tgtlift warn stdin && rm ./HoxD55.q
        """
    else if( params.distance == 'custom' )
        """
        echo $lastzFar
        lastz ${srcfile} ${tgtfile} ${params.custom} --format=lav |
            lavToPsl stdin stdout |
                liftUp -type=.psl stdout $srclift warn stdin |
                    liftUp -type=.psl -pslQ ${srcname}.${tgtname}.psl $tgtlift warn stdin 
        """
    else
        """
        echo "Distance not recognised"
        """
}
*/

