FROM jupyter/datascience-notebook:latest

RUN pip install awscli
USER root
RUN apt update -y \
    && apt install -y r-cran-rmysql
RUN arch=$(uname -m) && \
    if [ "${arch}" == "arch64" ]; then \
        # Prevent libmamba from sporadically hanging on arm64 under QEMU
        # <https://github.com/mamba-org/mamba/issues/1611>
        export G_SLICE=always-malloc; \
    fi && \
    mamba install --quiet --yes \
        'r-rmysql' \
    && mamba clean --all -f -y
RUN echo "jovyan ALL=(ALL)	NOPASSWD: ALL" >> /etc/sudoers

COPY build/palo_alto.crt /usr/local/share/ca-certificates/
RUN apt update & \
    apt install ca-certificates & \
    /usr/sbin/update-ca-certificates
    
USER jovyan
RUN mkdir ~/data
