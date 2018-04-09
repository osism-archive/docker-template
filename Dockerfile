FROM ubuntu:18.04
LABEL maintainer="Betacloud Solutions GmbH (https://www.betacloud-solutions.de)"

ARG VERSION
ENV VERSION ${VERSION:-latest}

ENV DEBIAN_FRONTEND noninteractive

ENV USER_ID ${USER_ID:-45000}
ENV GROUP_ID ${GROUP_ID:-45000}

USER root

ADD files/run.sh /run.sh

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y \
        bash

RUN groupadd -g $GROUP_ID dragon \
    && useradd -g dragon -u $USER_ID -m -d /home/dragon dragon

RUN apt-get clean \
    && rm -rf \
      /var/lib/apt/lists/* \
      /var/tmp/*

USER dragon
WORKDIR /home/dragon

CMD ["/run.sh"]
