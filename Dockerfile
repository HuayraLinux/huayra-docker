FROM debian:jessie

MAINTAINER Mauro <mauro@sdf.org>

ENV USER huayra
ENV UID 1000
ENV SUDOGRP sudo

ENV HOME /pkg
ENV PATH $PATH:$HOME/bin

ENV DEBIAN_FRONTEND noninteractive

COPY ["config/sources.list.d/huayra.list", "/etc/apt/sources.list.d/huayra.list"]

RUN apt-get update \
    && apt-get --force-yes -yq upgrade \
    && apt-get install --force-yes -yq \
                        huayra-archive-keyring \
                        packaging-dev wget \
                        piuparts pbuilder \
                        quilt sudo nano \
                        libwww-perl git \
                        fakeroot less \
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

COPY ["config/sudoers.d/pbuilder", "/etc/sudoers.d/pbuilder"]
COPY ["config/.pbuilderrc", "$HOME/.pbuilderrc"]
COPY ["config/bin/hpkg.py", "$HOME/bin/hpkg"]

RUN chmod +x $HOME/bin/hpkg \
    && chown -Rh $USER:$USER -- $HOME

USER $USER

WORKDIR $HOME
