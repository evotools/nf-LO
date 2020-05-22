FROM ubuntu:18.04
WORKDIR /app

# Install ubuntu dependencies
RUN apt update

# Install python and other dependencies
RUN apt install -y wget git ||  apt install --fix-missing -y wget git
RUN apt install -y python3 || apt install --fix-missing -y python3
RUN apt install -y gcc ||  apt install --fix-missing -y gcc
RUN apt install -y make || apt install --fix-missing -y make

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
    rm -rf /app/lastz
RUN cd /app && \
    wget http://last.cbrc.jp/last-*.zip && unzip last-1061.zip && \
    cd ./last-*/scripts && \
    2to3 maf-convert && mv maf-convert /usr/local/bin && chmod a+x /usr/local/bin/maf-convert && \
    cd /app && rm -r /app/last-*
RUN apt remove -y wget git
RUN chmod a+x /usr/local/bin/*
