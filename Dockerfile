FROM ubuntu:18.04
WORKDIR /app

# Install ubuntu dependencies
RUN cat /etc/apt/sources.list

# Changing to US archives of UBUNTU
RUN sed -i'' 's/archive\.ubuntu\.com/us\.archive\.ubuntu\.com/' /etc/apt/sources.list

# Install deps
RUN apt-get -qq update
RUN apt-get -qq install -y wget git 
RUN apt-get -qq install -y build-essential
RUN apt-get -qq install -y python make linux-libc-dev python-pip
RUN apt-get -qq install -y unzip perl 
RUN apt-get -qq install -y zlib1g-dev libkrb5-3

# Install Kent toolkit
WORKDIR /app
RUN for i in axtChain axtToMaf chainAntiRepeat chainMergeSort \
        chainNet chainPreNet chainStitchId chainSplit chainToAxt \
        faSplit faToTwoBit liftOver liftUp \
        mafCoverage netChainSubset netSyntenic twoBitInfo lavToPsl; do \
            wget https://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/"${i}" && \
            mv ${i} /usr/local/bin && \
            chmod a+x /usr/local/bin/${i}; \
    done

# Install blat
RUN wget https://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/blat/blat && \
        mv blat /usr/local/bin && \
        chmod a+x /usr/local/bin/blat

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

# Install GSAlign
RUN git clone https://github.com/hsinnan75/GSAlign.git && \
    cd GSAlign && \
    make all
ENV PATH=$PATH:/app/GSAlign/bin

# Install crossmap
RUN pip install CrossMap

# Clean image
RUN apt-get -qq remove git unzip && apt-get -qq autoclean -y && apt-get -qq autoremove -y 

# Make all executable
RUN chmod a+x /usr/local/bin/*

# Set correct workdir
WORKDIR /app/data