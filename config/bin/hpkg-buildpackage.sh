#!/bin/sh
# usage:
# $ hpkg-buildpackage pkg-holahuayra

###
#
# Variables
#
###

PKG=$1;
[ "$PKG" = "" ] && echo "Repositorio faltante" && exit 1;

HOME=/pkg
REPO_ROOT=${HOME}/repos
CHROOT_HOME=${HOME}/chroot
PKG_HOME=${REPO_ROOT}/${PKG};

clean(){
    [ -d $PKG_HOME ] && rm -fr $PKG_HOME;
}

###
#
# clean clone and build
#
###

clean;
hpkg $PKG clone build; 
