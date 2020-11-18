FROM ubuntu:20.04
WORKDIR /app

# Install ubuntu dependencies
RUN apt-get -qq update
RUN apt-get -qq install -y wget git 
RUN apt-get -qq install -y build-essential
RUN apt-get -qq install -y python2 make linux-libc-dev 
RUN apt-get -qq install -y unzip perl 
RUN apt-get -qq install -y zlib1g-dev

# Install Kent toolkit
WORKDIR /app
RUN for i in axtChain axtToMaf blat chainAntiRepeat chainMergeSort \
        chainNet chainPreNet chainStitchId chainSplit chainToAxt \
        faSplit faToTwoBit liftOver liftUp \
        mafCoverage netChainSubset netSyntenic twoBitInfo lavToPsl; do \
            wget https://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/${i} && \
            mv ${i} /usr/local/bin && \
            chmod a+x /usr/local/bin/${i}; \
    done

# Get lastz
RUN git clone https://github.com/UCSantaCruzComputationalGenomicsLab/lastz.git && \
    cd lastz && \
    make && \
    cp src/lastz /usr/local/bin && \
    chmod a+x /usr/local/bin/lastz && \
    cd /app && \
    rm -rf ./lastz

# Get maf-convert from last
RUN wget http://last.cbrc.jp/last-1061.zip && unzip last-1061.zip && \
    cd ./last-1061/ && make && make install && \
    cd /app && rm -r /app/last-*

# Get minimap2
RUN wget -q https://github.com/lh3/minimap2/releases/download/v2.17/minimap2-2.17_x64-linux.tar.bz2 && \
    tar -xvf minimap2-2.17_x64-linux.tar.bz2 && \
    cd minimap2-2.17_x64-linux && cp ./minimap2 ./paftools.js ./k8 /usr/local/bin && \
    chmod a+x /usr/local/bin/minimap2 && chmod a+x /usr/local/bin/paftools.js && chmod a+x /usr/local/bin/k8 && \
    cd /app && rm -rf ./minimap2-*

# Get mummer4
#RUN wget https://github.com/mummer4/mummer/releases/download/v4.0.0beta2/mummer-4.0.0beta2.tar.gz && \
#    tar xvfz mummer-4.0.0beta2.tar.gz && \
#    cd mummer-4.0.0beta2/ && ./configure && make && make install && \
#    cd /app && rm -rf ./mummer-4.0.0beta2/

# Clean image
RUN apt-get -qq remove wget git unzip && apt-get -qq autoclean -y && apt-get -qq autoremove -y 

# Make all executable
RUN chmod a+x /usr/local/bin/*
