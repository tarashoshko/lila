FROM ubuntu:22.04

RUN apt-get update && apt-get install -y openjdk-21-jdk tzdata gnupg && \
    rm -rf /var/lib/apt/lists/* && \
    echo "Europe/Kyiv" > /etc/timezone && \
    ln -sf /usr/share/zoneinfo/Europe/Kyiv /etc/localtime

RUN apt-get update && apt-get install -y wget && \
    echo "deb https://dl.bintray.com/sbt/debian /" | tee /etc/apt/sources.list.d/sbt.list && \
    wget -qO - https://keybase.io/sbt/keys/sbt-key.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/sbt.gpg > /dev/null && \
    apt-get update && apt-get install -y sbt && \
    rm -rf /var/lib/apt/lists/*

COPY . /home/vagrant/lila

WORKDIR /home/vagrant/lila
RUN sbt update

CMD ["sbt", "run"]
