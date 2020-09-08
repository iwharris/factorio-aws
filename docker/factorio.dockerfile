ARG UBUNTU_VERSION
FROM ubuntu:${UBUNTU_VERSION}
RUN apt-get update && apt-get -y upgrade

RUN apt-get install -y \
	jq \
	wget \
	xz-utils

ARG FACTORIO_VERSION
ARG FACTORIO_ROOT

ENV FACTORIO_ROOT="${FACTORIO_ROOT}"
ENV SCRIPTS_DIR="${FACTORIO_ROOT}/scripts"

WORKDIR /tmp

# Download factorio headless server
RUN wget -q -O factorio.tar.xz https://factorio.com/get-download/${FACTORIO_VERSION}/headless/linux64

# Extract to /opt; server root is /opt/factorio
RUN tar -C /opt -xf factorio.tar.xz

WORKDIR ${FACTORIO_ROOT}

COPY "./scripts/*" "${SCRIPTS_DIR}/"

CMD [ "./scripts/docker-entrypoint.sh" ]
