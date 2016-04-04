FROM debian:jessie

MAINTAINER Mauro <mauro@sdf.org>

ENV USER huayra
ENV UID 1000

ENV HOME /pkg
ENV PATH $PATH:$HOME/bin

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
    && apt-get -y upgrade \
    && apt-get install -yq packaging-dev \
                        piuparts pbuilder \
                        quilt nano \
                        libwww-perl git \
                        fakeroot \
    --no-install-recommends \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -u $UID -m -d $HOME -s /usr/sbin/nologin $USER \
    && mkdir -p $HOME \
    && chown -Rh $USER:$USER -- $HOME

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
