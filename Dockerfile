FROM nfcore/base:latest
LABEL authors="Andrea Talenti" \
      description="Docker image containing all software for the nf-LO pipeline"

# Install the conda environment
COPY environment.yml /
RUN conda env create -f /environment.yml && conda clean -a

# Add conda installation dir to PATH (instead of doing 'conda activate')
ENV PATH /opt/conda/envs/nf-LO/bin:$PATH

# Dump the details of the installed packages to a file for posterity
RUN conda env export --name nf-LO > nf-LO.yml

# Instruct R processes to use these empty files instead of clashing with a local version
RUN touch .Rprofile
RUN touch .Renviron
