FROM ghcr.io/parkervcp/yolks:ubuntu

LABEL org.opencontainers.image.source=https://github.com/TU_USUARIO/mta-fastdl-docker
LABEL org.opencontainers.image.description="MTA:SA Server with FastDL and MySQL - Powered by Trident Sky"
LABEL org.opencontainers.image.vendor="Trident Sky - www.tridentsky.net"

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    nginx-light \
    libmysqlclient21 \
    libncurses5 \
    libncursesw5 \
    curl \
    wget \
    tar \
    unzip \
    ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container

CMD ["/bin/bash"]
