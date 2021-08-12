
// Pre-defined chaining parameters 
chainNear="-minScore=5000 -linearGap=medium"
chainMedium="-minScore=3000 -linearGap=medium"
chainFar="-minScore=5000 -linearGap=loose"

// Import mafTools, if specified
if (params.mafTools){ mafTools_ch=file(params.mafTools) }

process axtchain_near {
    tag "axtchain_n"
    publishDir "${params.outdir}/singlechains", mode: params.publish_dir_mode, overwrite: true
    label 'small'

    input:
        tuple val(srcname), val(tgtname), file(psl) 
        file twoBitS
        file twoBitT

    output:
        path "${srcname}.${tgtname}.chain", emit: chain_files_ch

    stub:
    """
    touch ${srcname}.${tgtname}.chain
    """

    script:
    """
    axtChain $chainNear -verbose=0 -psl $psl ${twoBitS} ${twoBitT} stdout | chainAntiRepeat ${twoBitS} ${twoBitT} stdin stdout > ${srcname}.${tgtname}.chain
    """
}

process axtchain_medium {
    tag "axtchain_m"
    publishDir "${params.outdir}/singlechains", mode: params.publish_dir_mode, overwrite: true
    label 'small'

    input:
        tuple val(srcname), val(tgtname), file(psl) 
        file twoBitS
        file twoBitT

    output:
        path "${srcname}.${tgtname}.chain", emit: chain_files_ch

    stub:
    """
    touch ${srcname}.${tgtname}.chain
    """

    script:
    """
    axtChain $chainMedium -verbose=0 -psl $psl ${twoBitS} ${twoBitT} stdout | chainAntiRepeat ${twoBitS} ${twoBitT} stdin stdout > ${srcname}.${tgtname}.chain
    """
}

process axtchain_far {
    tag "axtchain_f"
    publishDir "${params.outdir}/singlechains", mode: params.publish_dir_mode, overwrite: true
    label 'small'

    input:
        tuple val(srcname), val(tgtname), file(psl) 
        file twoBitS
        file twoBitT

    output:
        path "${srcname}.${tgtname}.chain", emit: chain_files_ch

    stub:
    """
    touch ${srcname}.${tgtname}.chain
    """

    script:
    """
    axtChain $chainFar -verbose=0 -psl $psl ${twoBitS} ${twoBitT} stdout | chainAntiRepeat ${twoBitS} ${twoBitT} stdin stdout > ${srcname}.${tgtname}.chain
    """        
}

process axtchain_custom {
    tag "axtchain_c"
    publishDir "${params.outdir}/singlechains", mode: params.publish_dir_mode, overwrite: true
    label 'small'

    input:
        tuple val(srcname), val(tgtname), file(psl) 
        file twoBitS
        file twoBitT

    output:
        path "${srcname}.${tgtname}.chain", emit: chain_files_ch

    stub:
    """
    touch ${srcname}.${tgtname}.chain
    """

    script:
    """
    axtChain ${params.chainCustom} -verbose=0 -psl $psl ${twoBitS} ${twoBitT} stdout | chainAntiRepeat ${twoBitS} ${twoBitT} stdin stdout > ${srcname}.${tgtname}.chain
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
  
    stub:
    """
    touch rawchain.chain
    """

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
  
    stub:
    """
    touch liftover.chain
    touch netfile.net
    """

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
  
    stub:
    """
    touch netfile.net
    """

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
  
    stub:
    """
    touch netfile.synt.net
    """

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
  
    stub:
    """
    touch liftover.chain
    """

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

    stub:
    """
    touch ${params.chain_name}.maf
    """

    script:
    """
    chainToAxt ${chain} ${twoBitS} ${twoBitT} /dev/stdout | \
        axtToMaf /dev/stdin ${twoBitsizeS} ${twoBitsizeT} ${params.chain_name}.maf
    """
}


process name_maf_seq {
    tag "namemaf"
    publishDir "${params.outdir}/maf", mode: 'copy', overwrite: true
    label 'medium'
 
    input:
        path maf

    output:
        path "${maf.simpleName}.fixed.maf"

    stub:
    """
    touch ${maf.simpleName}.fixed.maf
    """

    script:
    $/
    #!/usr/bin/env python
    import sys
    
    n=0
    of = open("${maf.simpleName}.fixed.maf", "w")
    for line in open("$maf"):
        line = line.split()
        if len(line) == 0:
            of.write('\t'.join(line) + "\n")
            continue
        if "s" == line[0] and n == 1:
            line[1] = 'target.' + line[1]
            n = 0
            of.write('\t'.join(line) + "\n")
            continue
        if "s" == line[0] and n == 0:
            line[1] = 'source.' + line[1]
            n = 1
            of.write('\t'.join(line) + "\n")
            continue
        of.write('\t'.join(line) + "\n")
    /$
}


process mafstats {
    tag "mafstats"
    publishDir "${params.outdir}/stats", mode: 'copy', overwrite: true
    label 'medium'
 
    input:
        path final_maf
        val sourceName
        val targetName

    output:
        path "mafCoverage.*"
        path "mafIdentity.*"
        path "mafStats.*"

    stub:
    """
    touch mafCoverage.out
    touch mafIdentity.out
    touch mafStats.out
    """

    script:
    if (workflow.containerEngine)
    """
    mafCoverage -m ${final_maf} | sed 's/source/${sourceName}/g' | sed 's/target/${targetName}/g' > mafCoverage.out
    mafCoverage -m ${final_maf} --identity | sed 's/source/${sourceName}/g' | sed 's/target/${targetName}/g' > mafIdentity.out
    mafStats -m ${final_maf} | sed 's/source/${sourceName}/g' | sed 's/target/${targetName}/g' > mafStats.out    
    """
    else if (params.mafTools && !workflow.containerEngine)
    """
    ${mafTools_ch}/bin/mafCoverage -m ${final_maf} | sed 's/source/${sourceName}/g' | sed 's/target/${targetName}/g' > mafCoverage.out
    ${mafTools_ch}/bin/mafCoverage -m ${final_maf} --identity | sed 's/source/${sourceName}/g' | sed 's/target/${targetName}/g' > mafIdentity.out
    ${mafTools_ch}/bin/mafStats -m ${final_maf} | sed 's/source/${sourceName}/g' | sed 's/target/${targetName}/g' > mafStats.out
    """ 
    else 
    """
    if [ `which mafCoverage` ]; then
        mafCoverage -m ${final_maf} | sed 's/source/${sourceName}/g' | sed 's/target/${targetName}/g' > mafCoverage.out
        mafCoverage -m ${final_maf} --identity | sed 's/source/${sourceName}/g' | sed 's/target/${targetName}/g' > mafIdentity.out
    else
        touch mafCoverage.dum
        touch mafIdentity.dum
    fi
    if [ `which mafStats` ]; then
        mafStats -m ${final_maf} | sed 's/source/${sourceName}/g' | sed 's/target/${targetName}/g' > mafStats.out    
    else
        touch mafStats.dum
    fi
    """
}

// Liftover functions
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

    stub:
    """
    touch ${params.chain_name}.bed
    touch ${params.chain_name}.unmapped.bed
    """

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

    stub:
    """
    touch ${params.chain_name}.${params.annotation_format}
    """

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

process features_stats {
    tag "feat_stats"
    publishDir "${params.outdir}/stats", mode: params.publish_dir_mode, overwrite: true
    label 'medium'

    input:
        path all_feature
        path lifted_features

    output:
        path "features.txt"

    stub:
    """
    touch features.txt
    """

    script:
    if ( params.annotation_format == 'gff' || params.annotation_format == "gtf" || params.annotation_format == "bed" )
        """
        if file --dereference --mime-type "$lifted_features" | grep -q gzip\$; then
            liftedfeat=`gunzip -c ${lifted_features} | awk 'BEGIN{n=0};\$1!~"#"{n+=1}; END{print n}'`
            liftedgenes=`gunzip -c ${lifted_features} | awk 'BEGIN{n=0};\$1!~"#" && \$0~"gene" {n+=1}; END{print n}'`
        else 
            liftedfeat=`awk 'BEGIN{n=0};\$1!~"#"{n+=1}; END{print n}' ${lifted_features}`
            liftedgenes=`awk 'BEGIN{n=0};\$1!~"#" && \$0~"gene" {n+=1}; END{print n}' ${lifted_features}`
        fi
        if file --dereference --mime-type "$all_feature" | grep -q gzip\$; then
            allfeat=`gunzip -c ${all_feature} | awk 'BEGIN{n=0};\$1!~"#"{n+=1}; END{print n}'`
            allgenes=`gunzip -c ${all_feature} | awk 'BEGIN{n=0};\$1!~"#" && \$0~"gene" {n+=1}; END{print n}'`
        else 
            allfeat=`awk 'BEGIN{n=0};\$1!~"#"{n+=1}; END{print n}' ${all_feature}`
            allgenes=`awk 'BEGIN{n=0};\$1!~"#" && \$0~"gene" {n+=1}; END{print n}' ${all_feature}`
        fi
        echo nFEATURES nFEATURES_lifted nGENES nGENES_lifted > features.txt
        echo \$allfeat \$liftedfeat \$allgenes \$liftedgenes >> features.txt
        """
    else if ( params.annotation_format == 'vcf' )
        """
        if file --dereference --mime-type "$lifted_features" | grep -q gzip\$; then
            liftedvars=`gunzip -c ${lifted_features} | awk 'BEGIN{n=0};\$1!~"#"{n+=1}; END{print n}'`
        else 
            liftedvars=`awk 'BEGIN{n=0};\$1!~"#"{n+=1}; END{print n}' ${lifted_features}`
        fi
        if file --dereference --mime-type "$all_feature" | grep -q gzip\$; then
            allvars=`gunzip -c ${all_feature} | awk 'BEGIN{n=0};\$1!~"#"{n+=1}; END{print n}'`
        else 
            allvars=`awk 'BEGIN{n=0};\$1!~"#"{n+=1}; END{print n}' ${all_feature}`
        fi
        echo nFEATURES nFEATURES_lifted nGENES nGENES_lifted > features.txt
        echo \$allvars \$liftedvars NA NA>> features.txt
        """
    else if ( params.annotation_format == 'maf' )
        """
        if file --dereference --mime-type "$lifted_features" | grep -q gzip\$; then
            liftedfeat=`gunzip -c ${lifted_features} | awk 'BEGIN{n=0};\$1~"a" && \$1!~"#" {n+=1}; END{print n}'`
        else 
            liftedfeat=`awk 'BEGIN{n=0};\$1~"a" && \$1!~"#" {n+=1}; END{print n}' ${lifted_features}`
        fi
        if file --dereference --mime-type "$all_feature" | grep -q gzip\$; then
            allfeat=`gunzip -c ${all_feature} | awk 'BEGIN{n=0};\$1~"a" && \$1!~"#" {n+=1}; END{print n}'`
        else 
            allfeat=`awk 'BEGIN{n=0};\$1~"a" && \$1!~"#" {n+=1}; END{print n}' ${all_feature}`
        fi
        echo nFEATURES nFEATURES_lifted nGENES nGENES_lifted > features.txt
        echo \$allfeat \$liftedfeat NA NA>> features.txt
        """
    else if ( params.annotation_format == 'bam' )
        """
        liftedfeat=`bedtools bamtobed -i ${lifted_features} | awk 'END{print NR}'`
        allfeat=`bedtools bamtobed -i ${all_feature} | awk 'END{print NR}'`
        echo nFEATURES nFEATURES_lifted nGENES nGENES_lifted > features.txt
        echo \$allfeat \$liftedfeat NA NA>> features.txt
        """
}

process make_report {
    tag "report"
    publishDir "${params.outdir}/reports", mode: params.publish_dir_mode, overwrite: true
    label 'small'

    input:
    path mafstats
    path mafcov
    path mafidn
    path feat

    output:
    path "chainMetrics.html"

    stub:
    """
    touch chainMetrics.html
    """

    script:
    """
    cp ${baseDir}/assets/gatherMetrics.Rmd ./
    R -e "rmarkdown::render('gatherMetrics.Rmd',output_file='chainMetrics.html')"
    """
}