FROM ghcr.io/parkervcp/yolks:debian

LABEL org.opencontainers.image.source=https://github.com/TridentSky/mta-fastdl-docker
LABEL org.opencontainers.image.description="MTA:SA Server with FastDL and MySQL - Powered by Trident Sky"
LABEL org.opencontainers.image.vendor="Trident Sky - www.tridentsky.net"

USER root

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    nginx-light \
    libmysqlclient21 \
    libncurses5 \
    libncursesw5 \
    ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container

CMD ["/bin/bash"]
