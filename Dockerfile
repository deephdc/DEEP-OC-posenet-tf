ARG tag=1.12.0
ARG pyVer=py3

# Base image
FROM tensorflow/tensorflow:${tag}-${pyVer}
LABEL maintainer="Lara Lloret Iglesias <lloret@ifca.unican.es>"
LABEL version="0.1"
LABEL description="DEEP as a Service Container: Speech to text using Tensorflow"

# Add container's metadata to appear along the models metadata
ENV CONTAINER_MAINTAINER "Lara Lloret Iglesias <lloret@ifca.unican.es>"
ENV CONTAINER_VERSION "0.1"
ENV CONTAINER_DESCRIPTION "DEEP as a Service Container: Image Speech To Text"

# What user branch to clone (!)
ARG branch=master

RUN apt-get update

RUN apt-get install -y --no-install-recommends \
        curl \
        git \
	    libsm6  \
        libxrender1 \ 
        libxext6 \
        psmisc \
	    python3-tk

# We could shrink the dependencies, but this is a demo container, so...
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
         build-essential

WORKDIR /srv

# Install the image classifier package
RUN git clone -b $branch https://github.com/deephdc/posenet-tf.git && \
    cd posenet-tf && \
    python -m pip install -e . && \
    cd ..

# Install DEEPaaS
RUN pip install 'deepaas>=0.4.0'

# Useful tool to debug extensions loading
RUN python -m pip install entry_point_inspector

# install rclone
RUN apt-get install -y wget nano && \
    wget https://downloads.rclone.org/rclone-current-linux-amd64.deb && \
    dpkg -i rclone-current-linux-amd64.deb && \
    apt install -f && \
    rm rclone-current-linux-amd64.deb && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /root/.cache/pip/* && \
    rm -rf /tmp/*

# Expose API on port 5000 and tensorboard on port 6006.
EXPOSE 5000 6006

CMD ["deepaas-run", "--openwhisk-detect", "--listen-ip", "0.0.0.0", "--listen-port", "5000"]
