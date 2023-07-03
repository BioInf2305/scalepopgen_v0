FROM nfcore/base:2.1

###Best Practices to prepare Dockerfile is learnt from this paper: https://doi.org/10.1371/journal.pcbi.1008316


LABEL authors="upadhyay.maulik@gmail.com" \
      decription="Docker image containing tools requirement to run scalepopgen nextflow pipeline"

###Install the conda environment
COPY environment.yml /
RUN conda env create --quiet -f /environment.yml && conda clean -a

###Add conda install dir to PATH
ENV PATH /opt/conda/envs/scalepopgen_0.1.1/bin:$PATH
