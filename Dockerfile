FROM debian:jessie

MAINTAINER Mauro <mauro@sdf.org>

ENV USER huayra
ENV UID 1000
ENV SUDOGRP sudo

ENV HOME /pkg
ENV PATH $PATH:$HOME/bin

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
    && apt-get -y upgrade \
    && apt-get install -yq packaging-dev \
                        piuparts pbuilder \
                        quilt sudo nano \
                        libwww-perl git \
                        fakeroot \
    --no-install-recommends \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && useradd -u $UID -m -d $HOME -s /usr/sbin/nologin $USER \
    && adduser $USER $SUDOGRP \
    && mkdir -p $HOME \
    && mkdir -p $HOME/chroot \
    && mkdir -p $HOME/build \
    && mkdir -p $HOME/result \
    && mkdir -p $HOME/repos \
    && mkdir -p $HOME/bin

COPY ["config/sources.list.d/huayra.list", "/etc/apt/sources.list.d/huayra.list"]
COPY ["config/sudoers.d/pbuilder", "/etc/sudoers.d/pbuilder"]
COPY ["config/.pbuilderrc", "$HOME/.pbuilderrc"]
COPY ["config/bin/hpkg", "$HOME/bin/hpkg"]
COPY ["config/bin/hpkg-buildpackage", "$HOME/bin/hpkg-buildpackage"]
COPY ["config/chroot/huayra-torbellino-amd64.tgz", "$HOME/chroot/huayra-torbellino-amd64.tgz"]
COPY ["config/chroot/huayra-torbellino-i386.tgz", "$HOME/chroot/huayra-torbellino-i386.tgz"]

RUN chmod +x $HOME/bin/hpkg \
    && chmod +x $HOME/bin/hpkg-buildpackage \
    && chown -Rh $USER:$USER -- $HOME

USER $USER

WORKDIR $HOME
