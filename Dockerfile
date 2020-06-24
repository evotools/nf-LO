FROM alpine:latest
WORKDIR /app

# Install ubuntu dependencies
RUN apk update \                                                                                                                                                                                                                        
  &&   apk add ca-certificates wget \                                                                                                                                                                                                      
  &&   update-ca-certificates

# Install python and other dependencies
RUN apk add wget git python2 gcc make libc-dev unzip perl && rm -rf /var/cache/apk/*

# Install Kent toolkit
WORKDIR /app
RUN wget https://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/axtChain && mv axtChain /usr/local/bin && chmod a+x /usr/local/bin/axtChain
RUN wget https://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/blat/blat && mv blat /usr/local/bin/ && chmod +x /usr/local/bin/blat
RUN wget https://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/blat/gfClient && mv gfClient /usr/local/bin/ && chmod +x /usr/local/bin/gfClient
RUN wget https://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/blat/gfServer && mv gfServer /usr/local/bin/ && chmod +x /usr/local/bin/gfServer
RUN wget https://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/chainAntiRepeat && mv chainAntiRepeat /usr/local/bin && chmod a+x /usr/local/bin/chainAntiRepeat
RUN wget https://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/chainMergeSort && mv chainMergeSort /usr/local/bin && chmod a+x /usr/local/bin/chainMergeSort
RUN wget https://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/chainNet && mv chainNet /usr/local/bin && chmod a+x /usr/local/bin/chainNet
RUN wget https://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/chainPreNet && mv chainPreNet /usr/local/bin && chmod a+x /usr/local/bin/chainPreNet
RUN wget https://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/chainStitchId && mv chainStitchId /usr/local/bin && chmod a+x /usr/local/bin/chainStitchId
RUN wget https://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/chainSplit && mv chainSplit /usr/local/bin && chmod a+x /usr/local/bin/chainSplit
RUN wget https://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/faSplit && mv faSplit /usr/local/bin && chmod a+x /usr/local/bin/faSplit
RUN wget https://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/faToTwoBit && mv faToTwoBit /usr/local/bin && chmod a+x /usr/local/bin/faToTwoBit
RUN wget https://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/liftOver && mv liftOver /usr/local/bin && chmod a+x /usr/local/bin/liftOver
RUN wget https://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/liftUp && mv liftUp /usr/local/bin && chmod a+x /usr/local/bin/liftUp
RUN wget https://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/netChainSubset && mv netChainSubset /usr/local/bin && chmod a+x /usr/local/bin/netChainSubset
RUN wget https://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/netSyntenic && mv netSyntenic /usr/local/bin && chmod a+x /usr/local/bin/netSyntenic
RUN wget https://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/twoBitInfo && mv twoBitInfo /usr/local/bin && chmod a+x /usr/local/bin/twoBitInfo
RUN wget https://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/lavToPsl && mv lavToPsl /usr/local/bin && chmod a+x /usr/local/bin/lavToPsl

# Get lastz
RUN \
    git clone https://github.com/UCSantaCruzComputationalGenomicsLab/lastz.git && \
    cd lastz && \
    make && \
    cp src/lastz /usr/local/bin && \
    chmod a+x /usr/local/bin/lastz && \
    cd /app && \
    rm -rf ./lastz

# Get maf-convert from last
RUN \
    wget http://last.cbrc.jp/last-1061.zip && unzip last-1061.zip && \
    cd ./last-*/scripts && \
    mv maf-convert /usr/local/bin && chmod a+x /usr/local/bin/maf-convert && \
    cd /app && rm -r /app/last-*

# Get minimap2
RUN wget https://github.com/lh3/minimap2/releases/download/v2.17/minimap2-2.17_x64-linux.tar.bz2 && \
    tar -xvf minimap2-2.17_x64-linux.tar.bz2 && \
    cd minimap2-2.17_x64-linux && cp ./minimap2 ./paftools.js ./k8 /usr/local/bin && \
    chmod a+x /usr/local/bin/minimap2 && chmod a+x /usr/local/bin/paftools.js && chmod a+x /usr/local/bin/k8 && \
    cd /app && rm -rf ./minimap2-*

# Get mummer4
RUN wget https://github.com/mummer4/mummer/releases/download/v4.0.0beta2/mummer-4.0.0beta2.tar.gz && \
    tar xvfz mummer-4.0.0beta2.tar.gz && \
    cd mummer-4.0.0beta2/ && ./configure && make && make install && \
    cd /app && rm -rf ./mummer

# Clean image
RUN apk del wget git unzip

# Make all executable
RUN chmod a+x /usr/local/bin/*
