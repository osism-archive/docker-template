FROM ubuntu:20.04

ARG USER_ID=45000
ARG GROUP_ID=45000

ENV DEBIAN_FRONTEND noninteractive

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
      /usr/share/man/* \
    && echo > /var/log/lastlog

USER dragon
WORKDIR /home/dragon

CMD ["/run.sh"]

LABEL "org.opencontainers.image.documentation"="https://docs.osism.io" \
      "org.opencontainers.image.licenses"="ASL 2.0" \
      "org.opencontainers.image.source"="https://github.com/osism/docker-template" \
      "org.opencontainers.image.url"="https://www.osism.de" \
      "org.opencontainers.image.vendor"="Betacloud Solutions GmbH"
