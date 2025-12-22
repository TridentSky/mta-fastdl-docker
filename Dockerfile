FROM ubuntu:20.04

LABEL org.opencontainers.image.source=https://github.com/TridentSky/mta-fastdl-docker
LABEL org.opencontainers.image.description="MTA:SA Server with FastDL and MySQL - Powered by Trident Sky"
LABEL org.opencontainers.image.vendor="Trident Sky - www.tridentsky.net"

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    nginx \
    libmariadb3 \
    libncurses5 \
    libncursesw5 \
    curl \
    wget \
    tar \
    unzip \
    ca-certificates \
    iproute2 \
    tzdata && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN useradd -m -d /home/container -s /bin/bash container

USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container

CMD ["/bin/bash"]
