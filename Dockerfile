FROM debian:jessie

MAINTAINER Mauro <mauro@sdf.org>

ENV USER root
ENV HOME /pkg
ENV PATH $PATH:$HOME/bin
ENV DEBIAN_FRONTEND noninteractive

COPY ["etc/apt/sources.list.d/huayra.list", "/etc/apt/sources.list.d/huayra.list"]

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
    && mkdir -p $HOME \
    && mkdir -p $HOME/build \
    && mkdir -p $HOME/result \
    && mkdir -p $HOME/repos \
    && mkdir -p $HOME/bin

COPY ["bin/hpkg.py", "$HOME/bin/hpkg"]

RUN chmod +x $HOME/bin/hpkg \
    && chown -Rh $USER:$USER -- $HOME

USER $USER

WORKDIR $HOME
