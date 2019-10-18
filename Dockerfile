FROM ubuntu:18.04
LABEL maintainer="Betacloud Solutions GmbH (https://www.betacloud-solutions.de)"

ARG VERSION
ENV VERSION ${VERSION:-latest}

ENV DEBIAN_FRONTEND noninteractive

ENV USER_ID ${USER_ID:-45000}
ENV GROUP_ID ${GROUP_ID:-45000}

USER root

COPY files/run.sh /run.sh

RUN apt-get update \
    && apt-get install --no-install-recommends -y \
        bash \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd -g $GROUP_ID dragon \
    && useradd -g dragon -u $USER_ID -m -d /home/dragon dragon

RUN apt-get clean \
    && apt-get autoremove -y \
    && rm -rf \
      /var/tmp/*  \
      /usr/share/doc/* \
      /usr/share/man/*

USER dragon
WORKDIR /home/dragon

CMD ["/run.sh"]
