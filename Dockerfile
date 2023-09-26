FROM condaforge/mambaforge:23.1.0-3

###Best Practices to prepare Dockerfile is learnt from this paper: https://doi.org/10.1371/journal.pcbi.1008316, although not a large docker file ! ;)

LABEL authors="upadhyay.maulik@gmail.com" \
      decription="Docker image containing tools requirement to run scalepopgen nextflow pipeline"

###Install the conda environment
COPY environment.yml /
RUN mamba env create --quiet -f /environment.yml && mamba clean -a

###Add conda install dir to PATH
ENV PATH /opt/conda/envs/scalepopgen_0.1.1/bin:$PATH
ENV PYTHONPATH="/opt/conda/envs/scalepopgen_0.1.1/lib/python3.10/site-packages:${PYTHONPATH}"
