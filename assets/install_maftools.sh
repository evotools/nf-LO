#!/bin/bash

if [ ! -e ./bin ]; then 
    mkdir ./bin; 
fi
cd bin

unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     machine=Linux;;
    Darwin*)    machine=Mac;;
    #CYGWIN*)    machine=Cygwin;;
    #MINGW*)     machine=MinGw;;
    *)          machine="UNKNOWN:${unameOut}"
esac
echo ${machine}

if [ "$(uname)" == "Darwin" ]; then
    if [ ! `which brew` ]; then /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; fi
    if [ ! `which gcc-9` ]; then brew install gcc@9; fi 

    git clone https://github.com/ComparativeGenomicsToolkit/sonLib.git && \
        cd sonLib && \
        CC="gcc-9" CXX="g++-9" make && \
        cd ..

    git clone https://github.com/ComparativeGenomicsToolkit/pinchesAndCacti.git && \
        cd pinchesAndCacti && \
        CC="gcc-9" CXX="g++-9" make && \
        cd ..

    git clone https://github.com/dentearl/mafTools.git && \
        cd mafTools
    sed -i 's/clang/gcc\-9/g' inc/common.mk
    sed -i 's/clang++/g++\-9/g' inc/common.mk
    sed -i 's/\ \-Wno\-unused\-but\-set\-variable//g' inc/common.mk
    sed -i 's/\ \-Wall//g' inc/common.mk
    sed -i 's/\ \-Werror//g' inc/common.mk
    sed -i 's/\-stdlib\=libstdc++/\-static\-libstdc++/g' inc/common.mk
    sed -i 's/char\ fmtName\[10\]/char\ fmtName\[30\]/g' lib/sharedMaf.c
    sed -i 's/char\ fmtName\[10\]/char\ fmtName\[30\]/g' mafComparator/src/comparatorAPI.c
    sed -i 's/char\ fmtName\[10\]/char\ fmtName\[30\]/g' mafToFastaStitcher/src/mafToFastaStitcherAPI.c
    make && chmod a+x ./bin/* && mv ./bin/* ../
    cd ../ && rm -rf mafTools pinchesAndCacti sonLib
fi

if [ "$(uname)" == "Linux" ]; then
    git clone https://github.com/ComparativeGenomicsToolkit/sonLib.git && \
        cd sonLib && \
        make && \
        cd ..

    git clone https://github.com/ComparativeGenomicsToolkit/pinchesAndCacti.git && \
        cd pinchesAndCacti && \
        make && \
        cd ..

    git clone https://github.com/dentearl/mafTools.git && \
        cd mafTools
    sed -i 's/\${cxx}/\${cxx}\ \-lm/g' */Makefile
    sed -i 's/char\ fmtName\[10\]/char\ fmtName\[30\]/g' lib/sharedMaf.c
    sed -i 's/char\ fmtName\[10\]/char\ fmtName\[30\]/g' mafToFastaStitcher/src/mafToFastaStitcherAPI.c
    make && chmod a+x ./bin/* && mv ./bin/* ../
    cd ../ && rm -rf mafTools pinchesAndCacti sonLib
fi

# Make all executable once more
cd ../
chmod a+x ./bin/*