ARG UBUNTU_VERSION
FROM ubuntu:${UBUNTU_VERSION}
RUN apt-get update && apt-get -y upgrade

RUN apt-get install -y \
	wget \
	xz-utils

ARG FACTORIO_VERSION

ENV FACTORIO_VERSION=${FACTORIO_VERSION}

WORKDIR /workdir

# Download factorio headless server
RUN wget -q -O factorio.tar.xz https://factorio.com/get-download/${FACTORIO_VERSION}/headless/linux64

RUN tar -xvf factorio.tar.xz

RUN ls -al



