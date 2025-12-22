FROM ghcr.io/parkervcp/yolks:debian

LABEL org.opencontainers.image.source=https://github.com/TridentSky/mta-fastdl-docker
LABEL org.opencontainers.image.description="MTA:SA Server with FastDL and MySQL - Powered by Trident Sky"
LABEL org.opencontainers.image.vendor="Trident Sky - www.tridentsky.net"

USER root

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    nginx \
    libncurses5 \
    libncursesw5 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY --chown=container:container entrypoint.sh /entrypoint.sh
COPY --chown=container:container start.sh /opt/start.sh
RUN chmod +x /entrypoint.sh && chmod +x /opt/start.sh

USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container

ENTRYPOINT ["/entrypoint.sh"]
