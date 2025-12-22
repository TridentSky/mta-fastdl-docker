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
    default-libmysqlclient-dev \
    libmariadb3 && \
    wget http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb && \
    dpkg -i libssl1.1_1.1.1f-1ubuntu2_amd64.deb || apt-get install -f -y && \
    rm -f libssl1.1_1.1.1f-1ubuntu2_amd64.deb && \
    wget http://archive.ubuntu.com/ubuntu/pool/universe/m/mysql-5.6/libmysqlclient18_5.6.51-1ubuntu18.04_amd64.deb && \
    dpkg -i libmysqlclient18_5.6.51-1ubuntu18.04_amd64.deb || apt-get install -f -y && \
    rm -f libmysqlclient18_5.6.51-1ubuntu18.04_amd64.deb && \
    if [ -f /usr/lib/x86_64-linux-gnu/libmysqlclient.so.18 ]; then \
        cp /usr/lib/x86_64-linux-gnu/libmysqlclient.so.18 /usr/lib/libmysqlclient.so.16; \
    elif [ -f /usr/lib/x86_64-linux-gnu/libmysqlclient.so.18.* ]; then \
        cp /usr/lib/x86_64-linux-gnu/libmysqlclient.so.18.* /usr/lib/libmysqlclient.so.16; \
    else \
        ln -sf /usr/lib/x86_64-linux-gnu/libmariadb.so.3 /usr/lib/libmysqlclient.so.16; \
    fi && \
    chmod 755 /usr/lib/libmysqlclient.so.16 && \
    ldconfig && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY --chown=container:container entrypoint.sh /entrypoint.sh
COPY --chown=container:container start.sh /opt/start.sh
RUN chmod +x /entrypoint.sh && chmod +x /opt/start.sh

USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container

ENTRYPOINT ["/entrypoint.sh"]
