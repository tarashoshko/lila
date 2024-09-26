FROM ubuntu:22.04

RUN apt-get update && apt-get install -y openjdk-21-jdk tzdata && \
    rm -rf /var/lib/apt/lists/* && \
    echo "Europe/Kyiv" > /etc/timezone && \
    ln -sf /usr/share/zoneinfo/Europe/Kyiv /etc/localtime

RUN apt-get update && apt-get install -y wget && \
    wget -qO - https://dl.bintray.com/sbt/debian/sbt-debian.gpg | apt-key add - && \
    echo "deb https://dl.bintray.com/sbt/debian /" | tee /etc/apt/sources.list.d/sbt.list && \
    apt-get update && apt-get install -y sbt && \
    rm -rf /var/lib/apt/lists/*

COPY . /home/vagrant/lila

WORKDIR /home/vagrant/lila
RUN sbt update

CMD ["sbt", "run"]
