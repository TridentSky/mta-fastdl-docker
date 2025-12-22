FROM ghcr.io/parkervcp/yolks:debian

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
    libssl3 && \
    wget http://mirrors.kernel.org/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2.23_amd64.deb && \
    dpkg -i libssl1.1_1.1.1f-1ubuntu2.23_amd64.deb || true && \
    rm -f libssl1.1_1.1.1f-1ubuntu2.23_amd64.deb && \
    wget http://mirrors.kernel.org/ubuntu/pool/universe/m/mysql-5.7/libmysqlclient20_5.7.44-0ubuntu0.18.04.1_amd64.deb && \
    dpkg -i libmysqlclient20_5.7.44-0ubuntu0.18.04.1_amd64.deb || apt-get install -f -y && \
    rm -f libmysqlclient20_5.7.44-0ubuntu0.18.04.1_amd64.deb && \
    ln -sf /usr/lib/x86_64-linux-gnu/libmysqlclient.so.20 /usr/lib/libmysqlclient.so.16 && \
    ln -sf /usr/lib/x86_64-linux-gnu/libmysqlclient.so.20 /usr/lib/x86_64-linux-gnu/libmysqlclient.so.16 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY --chown=container:container entrypoint.sh /entrypoint.sh
COPY --chown=container:container start.sh /opt/start.sh
RUN chmod +x /entrypoint.sh && chmod +x /opt/start.sh

USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container

ENTRYPOINT ["/entrypoint.sh"]
