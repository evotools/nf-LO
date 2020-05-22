#!/bin/bash

if [ ! -e ./bin ]; then 
    mkdir /bin; 
fi
cd bin
if [ -e axtChain ]; then rm axtChain; fi; wget https://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/axtChain
if [ -e blat ]; then rm blat; fi; wget https://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/blat/blat
if [ -e gfClient ]; then rm gfClient; fi; wget https://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/blat/gfClient
if [ -e gfServer ]; then rm gfServer; fi; wget https://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/blat/gfServer
if [ -e chainAntiRepeat ]; then rm chainAntiRepeat; fi; wget https://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/chainAntiRepeat
if [ -e chainMergeSort ]; then rm chainMergeSort; fi; wget https://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/chainMergeSort
if [ -e chainNet ]; then rm chainNet; fi; wget https://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/chainNet
if [ -e chainPreNet ]; then rm chainPreNet; fi; wget https://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/chainPreNet
if [ -e chainStitchId ]; then rm chainStitchId; fi; wget https://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/chainStitchId
if [ -e chainSplit ]; then rm chainSplit; fi; wget https://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/chainSplit
if [ -e faSplit ]; then rm faSplit; fi; wget https://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/faSplit
if [ -e faToTwoBit ]; then rm faToTwoBit; fi; wget https://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/faToTwoBit
if [ -e liftOver ]; then rm liftOver; fi; wget https://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/liftOver
if [ -e liftUp ]; then rm liftUp; fi; wget https://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/liftUp
if [ -e netChainSubset ]; then rm netChainSubset; fi; wget https://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/netChainSubset
if [ -e netSyntenic ]; then rm netSyntenic; fi; wget https://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/netSyntenic
if [ -e twoBitInfo ]; then rm twoBitInfo; fi; wget https://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/twoBitInfo
if [ -e lavToPsl ]; then rm lavToPsl; fi; wget https://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/lavToPsl
if [ -e lavToAxt ]; then rm lavToAxt; fi; wget https://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/lavToAxt
# Install lastz
if [ -e lastz ]; then rm lastz; fi; git clone https://github.com/UCSantaCruzComputationalGenomicsLab/lastz.git && \
    cd lastz && \
    make && \
    cp src/lastz ../ && \
    cd .. && \
    rm -rf ./lastz
# Install maf-converter from last
pip3 install --upgrade 2to3
if [ -e maf-convert ]; then rm maf-convert; fi; wget http://last.cbrc.jp/last-1061.zip && unzip last-1061.zip && \
    cd ./last-*/scripts && \
    2to3 maf-convert && sed -i 's/python/python3/g' maf-convert && \
    mv maf-convert ../../ && cd ../../ && \
    rm -r /bin/last-*

# Install minimap2
if [ -e minimap2 ]; then rm minimap2 paftools.js k8; fi; wget https://github.com/lh3/minimap2/releases/download/v2.17/minimap2-2.17_x64-linux.tar.bz2 && \
    tar -xvf minimap2-2.17_x64-linux.tar.bz2 && \
    mv minimap2-2.17_x64-linux/minimap2 minimap2-2.17_x64-linux/paftools.js minimap2-2.17_x64-linux/k8 ./ && \
    rm -rf ./minimap2-*
# Clean-up
cd ../
chmod a+x ./bin/*