
/*
 * Step 1. Builds the genome index required by the mapping process and
 * the intervals for the analyses
 */

tgtChunkSize=params.tgtSize
srcChunkSize=params.srcSize
tgtOvlpSize=params.tgtOvlp

process make2bit {
    tag "twoBit"
    publishDir "$params.outdir/genome2bit", mode: params.publish_dir_mode, overwrite: true
    label 'medium'

    input:
    path source
    path target

    output:
    path "source.2bit", emit: twoBsrc
    path "target.2bit", emit: twoBtgt
    path "source.sizes", emit: twoBsrcNFO
    path "target.sizes", emit: twoBtgtNFO

    script:
    """
    faToTwoBit ${source} source.2bit
    twoBitInfo source.2bit source.sizes
    faToTwoBit ${target} target.2bit
    twoBitInfo target.2bit target.sizes
    """
}


process src2bit {
    tag "src2Bit"
    publishDir "$params.outdir/genome2bit", mode: params.publish_dir_mode, overwrite: true
    label 'medium'

    input:
    path source

    output:
    path "source.2bit", emit: twoBsrc
    path "source.sizes", emit: twoBsrcNFO

    script:
    """
    if [ `faSize -tab ${source} | awk '\$1=="baseCount" {print \$2}'` -lt 4000000000 ]; then
        faToTwoBit ${source} source.2bit
        twoBitInfo source.2bit source.sizes
    else
        faToTwoBit -long ${source} source.2bit
        twoBitInfo source.2bit source.sizes
    fi
    """
}

process tgt2bit {
    tag "tgt2Bit"
    publishDir "$params.outdir/genome2bit", mode: params.publish_dir_mode, overwrite: true
    label 'small'

    input:
    path target

    output:
    path "target.2bit", emit: twoBtgt
    path "target.sizes", emit: twoBtgtNFO

    script:
    """
    if [ `faSize -tab ${target} | awk '\$1=="baseCount" {print \$2}'` -lt 4000000000 ]; then
        faToTwoBit ${target} target.2bit
        twoBitInfo target.2bit target.sizes
    else
        faToTwoBit -long ${target} target.2bit
        twoBitInfo target.2bit target.sizes
    fi
    """
}

process makeooc {
    tag "ooc"
    publishDir "$params.outdir/splitfa_src"
    label 'medium'

    input:
    path source

    output:
    path "11.ooc", emit: ooc11
    path "12.ooc", emit: ooc12

    script:
    """
    blat ${source} /dev/null /dev/null -makeOoc=11.ooc -repMatch=1024
    blat ${source} /dev/null /dev/null -makeOoc=12.ooc -repMatch=1024 -tileSize=12
    """
}


process splitsrc {
    tag "splitsrc"
    label 'small'

    input:
    path source

    output:
    path "SPLIT_src", emit: srcsplit_ch
    path "source.lift", emit: src_lift_ch

    script:
    if ( params.aligner == "blat" || params.aligner == 'GSAlign' )
        """
        myvalue=`faSize -tab ${source} | awk '\$1=="maxSize" {print \$2}'`
        mkdir ./SPLIT_src && chmod a+rw ./SPLIT_src
        faSplit size -oneFile -lift=source.lift ${source} \$myvalue SPLIT_src/
        """
    else 
        """
        mkdir ./SPLIT_src && chmod a+rw ./SPLIT_src
        faSplit size -lift=source.lift ${source} ${srcChunkSize} SPLIT_src/
        """
}

process groupsrc {
    tag "groupsrc"
    label 'medium'

    input:
    path src_fld

    output:
    path "./CLUST_src", emit: srcclst_ch

    script:
    $/
    #!/usr/bin/env python

    def faSize(infile):
        return sum([len(line.strip()) for line in open(infile) if ">" not in line])


    if __name__ == "__main__":
        import os
        infld=os.path.realpath( "${src_fld}" )
        outFld = "./CLUST_src"
        os.mkdir(outFld)
        if not os.path.exists(outFld): os.mkdir(outFld)

        flist = os.listdir(infld)
        sizes = [faSize(os.path.join(infld, f)) for f in flist]
        tmpdata = list(zip(sizes,flist))
        tmpdata.sort(reverse = True)
        total = 0
        n = 0
        fname = "{}/src{}.fa"
        toWrite = []

        for n,(size,seq) in enumerate(tmpdata):
            total += size
            if total < int(${params.srcSize}):
                toWrite.append(os.path.join(infld, seq))
            else:
                if len(toWrite) > 0: 
                    outf = open(fname.format(outFld, n), "w" )
                    [outf.write(line) for f in toWrite for line in open(f) ]
                    outf.close()
                n += 1
                toWrite = [os.path.join(infld, seq)]
                total = size
        outf = open(fname.format(outFld, n), "w" )
        [outf.write(line) for f in toWrite for line in open(f) ]
        outf.close()
    /$

}


process splittgt {
    tag "splittgt"
    label 'small'

    input:
    path target


    output:
    path "SPLIT_tgt", emit: tgtsplit_ch
    path "target.lift", emit: tgt_lift_ch

    script:
    if( params.aligner == "blat" )
        """
        mkdir ./SPLIT_tgt && chmod a+rw ./SPLIT_tgt
        faSplit size -oneFile -lift=target.lift -extra=500 ${target} 4500 SPLIT_tgt/tmp
        """
    else
        """
        mkdir SPLIT_tgt && chmod a+rw SPLIT_tgt
        faSplit size -lift=target.lift -extra=${tgtOvlpSize} ${target} ${tgtChunkSize} SPLIT_tgt/
        """
}

process grouptgt {
    tag "grouptgt"
    label 'medium'

    input:
    path tgt_fld

    output:
    path "./CLUST_tgt", emit: tgtclst_ch

    script:
    if( params.aligner != "blat" )
    $/
    #!/usr/bin/env python

    def faSize(infile):
        return sum([len(line.strip()) for line in open(infile) if ">" not in line])


    if __name__ == "__main__":
        import os
        infld=os.path.realpath( "${tgt_fld}" )
        outFld = "./CLUST_tgt"
        if not os.path.exists(outFld): os.mkdir(outFld)

        flist = os.listdir(infld)
        sizes = [faSize(os.path.join(infld, f)) for f in flist]
        tmpdata = list(zip(sizes,flist))
        tmpdata.sort(reverse = True)
        total = 0
        n = 0
        fname = "./{}/tgt{}.fa"
        toWrite = []
        for n,(size,seq) in enumerate(tmpdata):
            total += size
            if total < int(${params.srcSize}):
                toWrite.append(os.path.join(infld, seq))
            else:
                if len(toWrite) > 0: 
                    outf = open(fname.format(outFld, n), "w" )
                    [outf.write(line) for f in toWrite for line in open(f) ]
                    outf.close()
                n += 1
                toWrite = [os.path.join(infld, seq)]
                total = size
        outf = open(fname.format(outFld, n), "w" )
        [outf.write(line) for f in toWrite for line in open(f) ]
        outf.close()
    /$
    else    
    $/
    #!/usr/bin/env python

    if __name__ == "__main__":
        import os
        infld=os.path.realpath( "${tgt_fld}" )
        outFld = "./CLUST_tgt"
        os.mkdir(outFld)
        if not os.path.exists(outFld): os.mkdir(outFld)

        fasta = os.listdir(infld)[0]
        nseqs = sum([1 for i in open(os.path.join("${tgt_fld}", fasta)) if ">" in i])
        totalL = sum([len(i.strip()) for i in open(os.path.join("${tgt_fld}", fasta)) if ">" not in i])
        nseqXfile = nseqs / round(int(totalL / int("${params.tgtSize}")))
        n = 1
        tot = 0
        fname = "{}/tgt{}.fa"
        toWrite = []
        outf = open(fname.format(outFld, n), "w" )
        for line in open(os.path.join("${tgt_fld}", fasta)):
            if ">" in line:
                tot += 1
            if tot > nseqXfile:
                outf.close()
                n += 1
                outf = open(fname.format(outFld, n), "w" )
                tot = 1
            outf.write(line)
    /$

}

/*
 * Step 2: Make pairs of chromosomes to process
 */

process pairs {
    tag "mkpairs"
    label 'small'

    input:
    path sources
    path targets

    output:
    path "pairs.csv", emit: pairspath

    script:
    $/
    #!/usr/bin/env python
    import os
    infld1 = os.path.realpath( "${sources}" )
    infld2 = os.path.realpath( "${targets}" )
    files1 = os.listdir(infld1)
    files2 = os.listdir(infld2)
    of = open("pairs.csv", "w")
    for f in files1:
        fname1 = os.path.join( infld1, f)
        bname1= '.'.join( f.split('.')[0:-1] )
        for f2 in files2:
            fname2 = os.path.join(infld2, f2)
            bname2 = '.'.join( f2.split('.')[0:-1] )
            of.write( "{},{},{},{}\n".format(bname1, fname1, bname2, fname2) )
    /$
}



process make2bitS {
    tag "twoBit"
    publishDir "$params.outdir/genome2bit", mode: params.publish_dir_mode, overwrite: true
    label 'small'

    input:
    path source

    output:
    path "source.2bit", emit: twoBsrc

    script:
    """
    faToTwoBit ${source} source.2bit
    """
}


process makeSizeS {
    tag "twoBit"
    publishDir "$params.outdir/genome2bit", mode: params.publish_dir_mode, overwrite: true
    label 'small'

    input:
    path src

    output:
    path "source.sizes", emit: sizesSrc

    script:
    """
    twoBitInfo ${src} source.sizes
    """
}

process make2bitT {
    tag "twoBit"
    publishDir "$params.outdir/genome2bit", mode: params.publish_dir_mode, overwrite: true
    label 'small'

    input:
    path target

    output:
    path "target.2bit", emit: twoBtgt

    script:
    """
    faToTwoBit ${target} target.2bit
    """
}

process makeSizeT {
    tag "twoBit"
    publishDir "$params.outdir/genome2bit", mode: params.publish_dir_mode, overwrite: true
    label 'small'

    input:
    path tgt

    output:
    path "target.sizes", emit: sizesTgt

    script:
    """
    twoBitInfo ${tgt} target.sizes
    """
}