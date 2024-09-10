# Pin base image
# See: https://hub.docker.com/r/continuumio/miniconda3
FROM continuumio/miniconda3@sha256:166ff37fba6c25fcad8516aa5481a2a8dfde11370f81b245c1e2e8002e68bcce
LABEL description="Base docker image with conda and util libraries"

# Install procps (so that Nextflow can poll CPU usage)
RUN apt-get update && \
    apt-get install -y procps && \
    apt-get clean -y

# Work in root
WORKDIR /root

# Install the conda environment
ARG ENV_NAME=nsforest
COPY environment.yaml /root
RUN conda env create --quiet --name ${ENV_NAME} --file /root/environment.yaml -y && \
    conda clean -a

# Enable activation of required conda environment when running the
# container with Docker
RUN cp .bashrc .bashrc.orig && \
    sed "s/conda activate base/conda activate $ENV_NAME/" .bashrc.orig > .bashrc

# Clone the repository and checkout the specified release
# TODO: Use release rather than a branch
ARG VERSION="origin/rl/add-nextflow-script"
RUN git clone https://github.com/ralatsdc/NSForest.git && \
    cd NSForest && \
    git checkout -t ${VERSION} && \
    git pull

# Copy script and link package
RUN cp NSForest/nsforest.py /usr/local/bin && \
    chmod a+x /usr/local/bin/nsforest.py && \
    ln -s /root/NSForest/nsforest /usr/local/bin/nsforest

# Add conda installation and root dirs to PATH (instead of doing
# 'conda activate' or specifiying path to tool)
ENV PATH="/opt/conda/envs/$ENV_NAME/bin:/root:$PATH"
