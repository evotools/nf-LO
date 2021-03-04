

chainNear="-minScore=5000 -linearGap=medium"
chainMedium="-minScore=3000 -linearGap=medium"
chainFar="-minScore=5000 -linearGap=loose"

process axtchain {
    tag "axtchain"
    publishDir "${params.outdir}/singlechains", mode: params.publish_dir_mode, overwrite: true
    label 'small'

    input:
        tuple val(srcname), val(tgtname), file(psl) 
        file twoBitS
        file twoBitT

    output:
        path "${srcname}.${tgtname}.chain", emit: chain_files_ch

    script:
    if (params.distance == 'custom')
        """
        axtChain ${params.chainCustom} -verbose=0 -psl $psl ${twoBitS} ${twoBitT} | chainAntiRepeat ${twoBitS} ${twoBitT} stdin stdout > ${srcname}.${tgtname}.chain
        """
    else if ( params.distance == 'near' || params.distance == "balanced" || params.distance == "same" || params.distance == "primate" )
        """
        axtChain $chainNear -verbose=0 -psl $psl ${twoBitS} ${twoBitT} stdout | chainAntiRepeat ${twoBitS} ${twoBitT} stdin stdout > ${srcname}.${tgtname}.chain
        """
    else if (params.distance == 'medium' || params.distance == 'general')
        """
        axtChain $chainMedium -verbose=0 -psl $psl ${twoBitS} ${twoBitT} stdout | chainAntiRepeat ${twoBitS} ${twoBitT} stdin stdout > ${srcname}.${tgtname}.chain
        """
    else if (params.distance == 'far')
        """
        axtChain $chainFar -verbose=0 -psl $psl ${twoBitS} ${twoBitT} stdout | chainAntiRepeat ${twoBitS} ${twoBitT} stdin stdout > ${srcname}.${tgtname}.chain
        """        
}


process chainMerge {
    tag "chainmerge"
    publishDir "${params.outdir}/rawchain", mode: params.publish_dir_mode, overwrite: true
    label 'medium'

    input: 
        file chains
        
    output: 
        path "rawchain.chain", emit: rawchain_ch  
  
    script:
        """
        chainMergeSort $chains | chainSplit run stdin -lump=1 
        mv run/000.chain ./rawchain.chain
        """
}

process chainNet_old{
    tag "chainnet"
    publishDir "${params.outdir}/chainnet", mode: 'copy', overwrite: true
    label 'medium'
 
    input:
        file rawchain  
        file twoBitS
        file twoBitT
        file twoBitsizeS
        file twoBitsizeT
        
    output: 
        path "liftover.chain", emit: liftover_ch  
        path "netfile.net", emit: netfile_ch  
  
    script:
    if ( params.aligner != "blat" & params.aligner != "nucmer" & params.aligner != "GSAlign")
    """
    chainPreNet ${rawchain} ${twoBitsizeS} ${twoBitsizeT} stdout |
        chainNet -verbose=0 stdin ${twoBitsizeS} ${twoBitsizeT} stdout /dev/null | netSyntenic stdin netfile.net
    netChainSubset -verbose=0 netfile.net ${rawchain} stdout | chainStitchId stdin stdout > liftover.chain
    """
}

process chainNet{
    tag "chainnet"
    publishDir "${params.outdir}/chainnet", mode: 'copy', overwrite: true
    label 'medium'
 
    input:
        file rawchain  
        file twoBitS
        file twoBitT
        file twoBitsizeS
        file twoBitsizeT
        
    output: 
        path "netfile.net"
  
    script:
    """
    chainPreNet ${rawchain} ${twoBitsizeS} ${twoBitsizeT} stdout |
        chainNet -verbose=0 stdin ${twoBitsizeS} ${twoBitsizeT} netfile.net /dev/null 
    """
}

process netSynt {
    tag "netSyntenic"
    publishDir "${params.outdir}/chainnet", mode: 'copy', overwrite: true
    label 'medium'
 
    input:
        file netfile  
        
    output: 
        path "netfile.synt.net", emit: netfile_ch  
  
    script:
    """
    netSyntenic ${netfile} netfile.synt.net
    """
}

process chainsubset{
    tag "chainsubs"
    publishDir "${params.outdir}/chainnet", mode: 'copy', overwrite: true
    label 'medium'
 
    input:
        file netfile
        file rawchain
        
    output: 
        path "liftover.chain", emit: liftover_ch  
  
    script:
    """
    netChainSubset -verbose=0 ${netfile} ${rawchain} stdout | chainStitchId stdin stdout > liftover.chain
    """
}

process chain2maf {
    tag "chainmaf"
    publishDir "${params.outdir}/maf", mode: 'copy', overwrite: true
    label 'medium'
 
    input:
        path chain  
        path twoBitS
        path twoBitT
        path twoBitsizeS
        path twoBitsizeT

    output:
        path "${params.chain_name}.maf"

    script:
    """
    chainToAxt ${chain} ${twoBitS} ${twoBitT} /dev/stdout | \
        axtToMaf /dev/stdin ${twoBitsizeS} ${twoBitsizeT} ${params.chain_name}.maf
    """
}

process liftover{
    tag "liftover"
    publishDir "${params.outdir}/lifted", mode: params.publish_dir_mode, overwrite: true
    label 'medium'
 
    input:
        path chain
        path annotation

    output:
        path "${params.chain_name}.bed", emit: lifted_ch
        path "${params.chain_name}.unmapped.bed", emit: unmapped_ch

    script:
    """
    liftOver ${annotation} ${chain} ${params.chain_name}.bed ${params.chain_name}.unmapped.bed
    """
}



process crossmap{
    tag "crossmap"
    publishDir "${params.outdir}/lifted", mode: params.publish_dir_mode, overwrite: true
    label 'medium'
 
    input:
        path chain
        path annotation
        path tgt_ch

    output:
        path "${params.chain_name}.${params.annotation_format}", emit: lifted_ch
        path "*unmap*",  optional: true, emit: unmapped_ch

    script:
    if ( params.annotation_format == 'bam' )
        """
        CrossMap.py bam -a ${chain} ${annotation} ${params.chain_name}.${params.annotation_format} 
        """
    else if ( params.annotation_format == 'vcf' )
        """
        CrossMap.py vcf -a ${chain} ${annotation} ${tgt_ch} ${params.chain_name}.${params.annotation_format} 
        """
    else if ( params.annotation_format == 'maf' )
        """
        CrossMap.py maf -a ${chain} ${annotation} ${tgt_ch} ${params.maf_tgt_name} ${params.chain_name}.${params.annotation_format} 
        """
    else 
        """
        CrossMap.py ${params.annotation_format} ${chain} ${annotation} ${params.chain_name}.${params.annotation_format}     
        """
}
