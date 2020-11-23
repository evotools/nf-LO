FROM continuumio/miniconda:4.7.12-alpine
WORKDIR /app

# Install ubuntu dependencies
RUN cat /etc/apt/sources.list

# Changing to US archives of UBUNTU
RUN sed -i'' 's/archive\.ubuntu\.com/us\.archive\.ubuntu\.com/' /etc/apt/sources.list

LABEL authors="andrea.talenti@ed.ac.uk" \
      description="Docker image containing base requirements for nf-LO pipelines"

# Install procps so that Nextflow can poll CPU usage and 
# deep clean the apt cache to reduce image/layer size
RUN apt-get update \
 && apt-get install -y procps \
 && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Install the conda environment
COPY environment.yml /
RUN conda env create -f /environment.yml && conda clean -a

# Add conda installation dir to PATH (instead of doing 'conda activate')
ENV PATH /opt/conda/envs/nf-core-chipseq-1.2.1/bin:$PATH

# Dump the details of the installed packages to a file for posterity
RUN conda env export --name nf-core-chipseq-1.2.1 > nf-core-chipseq-1.2.1.yml

# Instruct R processes to use these empty files instead of clashing with a local version
RUN touch .Rprofile
RUN touch .Renviron

# Set correct workdir
WORKDIR /app/data