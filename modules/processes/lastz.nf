
lastzNear="B=0 C=0 E=150 H=0 K=4500 L=3000 M=254 O=600 T=2 Y=15000"
lastzMedium="B=0 C=0 E=30 H=0 K=3000 L=3000 M=50 O=400 T=1 Y=9400"
lastzFar="B=0 C=0 E=30 H=2000 K=2200 L=6000 M=50 O=400 T=2 Y=3400"
lastzPrimate="E=30 H=3000 K=5000 L=5000 M=10 O=400 T=1"
lastzGeneral="E=30 H=2200 K=3000 L=3000 O=400 T=1"

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


process lastz_primates{    
    tag "lastz_primates.${srcname}.${tgtname}"
    label 'medium'

    input: 
        tuple val(srcname), val(srcfile), val(tgtname), val(tgtfile) 
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
    echo $lastzPrimate
    echo "A C G T" > human_chimp.v2.q
    echo "90 -330 -236 -356" >> human_chimp.v2.q
    echo "-330 100 -318 -236" >> human_chimp.v2.q
    echo "-236 -318 100 -330" >> human_chimp.v2.q
    echo "-356 -236 -330 90" >> human_chimp.v2.q
    lastz ${srcfile} ${tgtfile} ${lastzPrimate} ‑‑allocate:traceback=2048.0M --ambiguous=iupac Q=./human_chimp.v2.q --format=lav |
        lavToPsl stdin stdout |
            liftUp -type=.psl stdout $srclift warn stdin |
                liftUp -type=.psl -pslQ ${srcname}.${tgtname}.psl $tgtlift warn stdin && rm ./human_chimp.v2.q
    """
}

process lastz_general{    
    tag "lastz_general.${srcname}.${tgtname}"
    label 'medium'

    input: 
        tuple val(srcname), val(srcfile), val(tgtname), val(tgtfile) 
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
    echo $lastzGeneral
    echo "A C G T" > general.q
    echo "91 -114 -31 -123" >> general.q
    echo "-114 100 -125 -31" >> general.q
    echo "-31 -125 100 -114" >> general.q
    echo "-123 -31 -114 91" >> general.q
    lastz ${srcfile} ${tgtfile} ${lastzGeneral} ‑‑allocate:traceback=2048.0M --ambiguous=iupac Q=./general.q --format=lav |
        lavToPsl stdin stdout |
            liftUp -type=.psl stdout $srclift warn stdin |
                liftUp -type=.psl -pslQ ${srcname}.${tgtname}.psl $tgtlift warn stdin && rm ./general.q
    """
}

process lastz_near{    
    tag "lastz_near.${srcname}.${tgtname}"
    label 'medium'

    input: 
        tuple val(srcname), val(srcfile), val(tgtname), val(tgtfile) 
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
    echo $lastzNear
    echo "A C G T" > human_chimp.v2.q
    echo "90 -330 -236 -356" >> human_chimp.v2.q
    echo "-330 100 -318 -236" >> human_chimp.v2.q
    echo "-236 -318 100 -330" >> human_chimp.v2.q
    echo "-356 -236 -330 90" >> human_chimp.v2.q
    lastz ${srcfile} ${tgtfile} ${lastzNear} --ambiguous=iupac Q=./human_chimp.v2.q --format=lav |
        lavToPsl stdin stdout |
            liftUp -type=.psl stdout $srclift warn stdin |
                liftUp -type=.psl -pslQ ${srcname}.${tgtname}.psl $tgtlift warn stdin && rm ./human_chimp.v2.q
    """
}

process lastz_medium{    
    tag "lastz_med.${srcname}.${tgtname}"
    label 'medium'

    input: 
        tuple val(srcname), val(srcfile), val(tgtname), val(tgtfile) 
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
    echo $lastzMedium
    lastz ${srcfile} ${tgtfile} ${lastzMedium} --ambiguous=iupac --format=lav |
        lavToPsl stdin stdout |
            liftUp -type=.psl stdout $srclift warn stdin |
                liftUp -type=.psl -pslQ ${srcname}.${tgtname}.psl $tgtlift warn stdin 
    """
}

process lastz_far{    
    tag "lastz_far.${srcname}.${tgtname}"
    label 'medium'

    input: 
        tuple val(srcname), val(srcfile), val(tgtname), val(tgtfile) 
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
    echo $lastzFar
    echo "A C G T" > HoxD55.q
    echo "91 -90 -25 -100" >> HoxD55.q
    echo "-90 100 -100 -25" >> HoxD55.q
    echo "-25 -100 100 -90" >> HoxD55.q
    echo "-100 -25 -90 91" >> HoxD55.q
    lastz ${srcfile} ${tgtfile} --ambiguous=iupac Q=./HoxD55.q ${lastzFar} --format=lav |
        lavToPsl stdin stdout |
            liftUp -type=.psl stdout $srclift warn stdin |
                liftUp -type=.psl -pslQ ${srcname}.${tgtname}.psl $tgtlift warn stdin && rm ./HoxD55.q
    """
}

process lastz_custom{    
    tag "lastz_cust.${srcname}.${tgtname}"
    label 'medium'

    input: 
        tuple val(srcname), val(srcfile), val(tgtname), val(tgtfile) 
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
    echo ${params.custom}
    lastz ${srcfile} ${tgtfile} ${params.custom} --ambiguous=iupac --format=lav |
        lavToPsl stdin stdout |
            liftUp -type=.psl stdout $srclift warn stdin |
                liftUp -type=.psl -pslQ ${srcname}.${tgtname}.psl $tgtlift warn stdin 
    """
}
