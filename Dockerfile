FROM debian:jessie

MAINTAINER Mauro <mauro@sdf.org>

ENV HOME /pkg
ENV PATH $PATH:$HOME/bin

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get install -y packaging-dev \
                       piuparts pbuilder \
                       quilt sudo nano \
                       libwww-perl git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p $HOME/chroot \
    && mkdir -p $HOME/build \
    && mkdir -p $HOME/result \
    && mkdir -p $HOME/repos \
    && mkdir -p $HOME/bin

COPY ["config/chroot/huayra-torbellino-amd64.tgz", "$HOME/chroot/huayra-torbellino-amd64.tgz"]
COPY ["config/chroot/huayra-torbellino-i386.tgz", "$HOME/chroot/huayra-torbellino-i386.tgz"]
COPY ["config/bin/build", "$HOME/bin/build"]
COPY ["config/.pbuilderrc", "$HOME/.pbuilderrc"]

RUN chmod +x $HOME/bin/build

USER $USER

WORKDIR $HOME
