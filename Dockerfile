FROM ubuntu:22.04

LABEL org.opencontainers.image.source=https://github.com/TridentSky/mta-fastdl-docker
LABEL org.opencontainers.image.description="MTA:SA Server with FastDL and MySQL - Powered by Trident Sky"
LABEL org.opencontainers.image.vendor="Trident Sky - https://tridentsky.net/"

USER root

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    nginx \
    libncurses5 \
    libncursesw5 \
    wget \
    ca-certificates \
    unzip \
    tar \
    iproute2 \
    tzdata && \
    wget -O /usr/lib/libmysqlclient.so.16 https://nightly.mtasa.com/files/modules/64/libmysqlclient.so.16 && \
    chmod 755 /usr/lib/libmysqlclient.so.16 && \
    ldconfig && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN useradd -m -d /home/container -s /bin/bash container

COPY --chown=container:container entrypoint.sh /entrypoint.sh
COPY --chown=container:container start.sh /opt/start.sh
RUN chmod +x /entrypoint.sh && chmod +x /opt/start.sh

USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container

ENTRYPOINT ["/entrypoint.sh"]
