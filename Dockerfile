FROM continuumio/miniconda3 AS build

LABEL authors="andrea.talenti@ed.ac.uk" \
      description="Docker image containing base requirements for nf-LO pipelines"

# Install the package as normal:
COPY environment.yml .

# Install mamba to speed up the process
RUN conda install -c conda-forge -y mamba

# Create the environment
RUN mamba env create -f environment.yml

# Install conda-pack:
RUN mamba install -c conda-forge conda-pack

# Use conda-pack to create a standalone enviornment
# in /venv:
RUN conda-pack -n nf-LO -o /tmp/env.tar && \
  mkdir /venv && cd /venv && tar xf /tmp/env.tar && \
  rm /tmp/env.tar

# We've put venv in same path it'll be in final image,
# so now fix up paths:
RUN /venv/bin/conda-unpack


# The runtime-stage image; we can use Debian as the
# base image since the Conda env also includes Python
# for us.
FROM debian:buster AS runtime

# Install procps in debian to make it compatible with reporting
RUN apt-get update && \
  apt install -y procps gcc g++ curl make pkg-config zlib1g-dev git python2.7 file && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Define working directory
WORKDIR /app

# Add minimal dependencies
RUN apt-get update -y -qq && \
    apt-get upgrade -y -qq && \
    apt-get install -y -qq make pkg-config zlib1g-dev git python2.7 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Link python2.7 to python
RUN ln /usr/bin/python2.7 /usr/bin/python

# Install mafTools
RUN git clone https://github.com/ComparativeGenomicsToolkit/sonLib.git && \
        cd sonLib && \
        make

RUN git clone https://github.com/ComparativeGenomicsToolkit/pinchesAndCacti.git && \
    cd pinchesAndCacti && \
    make

RUN git clone https://github.com/dentearl/mafTools.git && \
    cd mafTools && \
    sed -i 's/\${cxx}/\${cxx}\ \-lm/g' */Makefile && \
    sed -i 's/char\ fmtName\[10\]/char\ fmtName\[30\]/g' lib/sharedMaf.c && \
    sed -i 's/char\ fmtName\[10\]/char\ fmtName\[30\]/g' mafToFastaStitcher/src/mafToFastaStitcherAPI.c && \
    make && \
    cp ./bin/* /usr/local/bin && \
    chmod a+x /usr/local/bin/*

# Clean-up post installation
RUN rm -rf /app/*
RUN apt-get remove -y -qq python2.7 make pkg-config git && \
    apt-get clean -y -qq && \
    apt-get autoremove -y -qq && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Copy /venv from the previous stage:
COPY --from=build /venv /venv

# When image is run, run the code with the environment
# activated:
ENV PATH /venv/bin/:$PATH
SHELL ["/bin/bash", "-c"]
