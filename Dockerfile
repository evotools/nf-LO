FROM alpine:latest
WORKDIR /app

# Install ubuntu dependencies
RUN apk update \                                                                                                                                                                                                                        
  &&   apk add ca-certificates wget \                                                                                                                                                                                                      
  &&   update-ca-certificates

# Install python and other dependencies
RUN apk add wget git python gcc make libc-dev unzip && rm -rf /var/cache/apk/*

# Install packages
RUN cd /app && wget https://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/axtChain && mv axtChain /usr/local/bin && chmod a+x /usr/local/bin/axtChain && cd ../
RUN cd /app && wget https://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/blat/blat && mv blat /usr/local/bin/ && chmod +x /usr/local/bin/blat && cd ../
RUN cd /app && wget https://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/blat/gfClient && mv gfClient /usr/local/bin/ && chmod +x /usr/local/bin/gfClient && cd ../
RUN cd /app && wget https://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/blat/gfServer && mv gfServer /usr/local/bin/ && chmod +x /usr/local/bin/gfServer && cd ../
RUN cd /app && wget https://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/chainAntiRepeat && mv chainAntiRepeat /usr/local/bin && chmod a+x /usr/local/bin/chainAntiRepeat && cd ../
RUN cd /app && wget https://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/chainMergeSort && mv chainMergeSort /usr/local/bin && chmod a+x /usr/local/bin/chainMergeSort && cd ../
RUN cd /app && wget https://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/chainNet && mv chainNet /usr/local/bin && chmod a+x /usr/local/bin/chainNet && cd ../
RUN cd /app && wget https://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/chainPreNet && mv chainPreNet /usr/local/bin && chmod a+x /usr/local/bin/chainPreNet && cd ../
RUN cd /app && wget https://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/chainStitchId && mv chainStitchId /usr/local/bin && chmod a+x /usr/local/bin/chainStitchId && cd ../
RUN cd /app && wget https://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/chainSplit && mv chainSplit /usr/local/bin && chmod a+x /usr/local/bin/chainSplit && cd ../
RUN cd /app && wget https://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/faSplit && mv faSplit /usr/local/bin && chmod a+x /usr/local/bin/faSplit && cd ../
RUN cd /app && wget https://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/faToTwoBit && mv faToTwoBit /usr/local/bin && chmod a+x /usr/local/bin/faToTwoBit && cd ../
RUN cd /app && wget https://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/liftOver && mv liftOver /usr/local/bin && chmod a+x /usr/local/bin/liftOver && cd ../
RUN cd /app && wget https://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/liftUp && mv liftUp /usr/local/bin && chmod a+x /usr/local/bin/liftUp && cd ../
RUN cd /app && wget https://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/netChainSubset && mv netChainSubset /usr/local/bin && chmod a+x /usr/local/bin/netChainSubset && cd ../
RUN cd /app && wget https://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/netSyntenic && mv netSyntenic /usr/local/bin && chmod a+x /usr/local/bin/netSyntenic && cd ../
RUN cd /app && wget https://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/twoBitInfo && mv twoBitInfo /usr/local/bin && chmod a+x /usr/local/bin/twoBitInfo && cd ../
RUN cd /app && wget https://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/lavToPsl && mv lavToPsl /usr/local/bin && chmod a+x /usr/local/bin/lavToPsl && cd ../
RUN cd /app && wget https://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/lavToAxt && mv lavToAxt /usr/local/bin && chmod a+x /usr/local/bin/lavToAxt && cd ../
RUN cd /app && \
    git clone https://github.com/UCSantaCruzComputationalGenomicsLab/lastz.git && \
    cd lastz && \
    make && \
    cp src/lastz /usr/local/bin && \
    chmod a+x /usr/local/bin/lastz && \
    cd /app && \
    rm -rf ./lastz
RUN cd /app && \
    wget http://last.cbrc.jp/last-1061.zip && unzip last-1061.zip && \
    cd ./last-*/scripts && \
    mv maf-convert /usr/local/bin && chmod a+x /usr/local/bin/maf-convert && \
    cd /app && rm -r /app/last-*
RUN cd /app && wget https://github.com/lh3/minimap2/releases/download/v2.17/minimap2-2.17_x64-linux.tar.bz2 && \
    tar -xvf minimap2-2.17_x64-linux.tar.bz2 && \
    cd minimap2-2.17_x64-linux && cp ./minimap2 ./paftools.js ./k8 /usr/local/bin && \
    chmod a+x /usr/local/bin/minimap2 && chmod a+x /usr/local/bin/paftools.js && chmod a+x /usr/local/bin/k8 && \
    cd /app && rm -rf ./minimap2-*
RUN apk del wget git unzip
RUN chmod a+x /usr/local/bin/*
