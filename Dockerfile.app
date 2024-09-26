FROM ubuntu:22.04

RUN truncate -s0 /tmp/preseed.cfg && \
    (echo "tzdata tzdata/Areas select Europe" >> /tmp/preseed.cfg) && \
    (echo "tzdata tzdata/Zones/Europe select Kyiv" >> /tmp/preseed.cfg) && \
    debconf-set-selections /tmp/preseed.cfg && \
    rm -f /etc/timezone /etc/localtime && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    apt-get install -y tzdata

RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    software-properties-common \
    build-essential \
    tcl \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y \
    openjdk-21-jdk \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y \
    redis-server && \
    rm -rf /var/lib/apt/lists/*

ARG LILA_VERSION

COPY lila_${LILA_VERSION}_all.deb /tmp/lila_${LILA_VERSION}_all.deb

RUN dpkg -i /tmp/lila_${LILA_VERSION}_all.deb \
    && apt-get install -f -y \
    && rm /tmp/lila_${LILA_VERSION}_all.deb

WORKDIR /usr/share/lila

CMD ["bin/lila"]
