#!/bin/sh
# usage:
# $ hpkg pkg-holahuayra clone build

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

CHROOT_AMD64=huayra-torbellino-amd64.tgz
CHROOT_I386=huayra-torbellino-i386.tgz

REPO_GITHUB=http://github.com/HuayraLinux/${PKG}

PDEBUILD=`which pdebuild`;
PDEBUILD="${PDEBUILD} --pbuildersatisfydepends /usr/lib/pbuilder/pbuilder-satisfydepends"

###
#
# Funciones
#
###

git_clone(){
###
#
# Clonamos y ejecutamos `uscan` en caso de tener watchfile.
#
###

    git clone $REPO_GITHUB;

    # si el clon salio OK
    if [ -z "$!" ];
    then

        # si tiene watchfile
        if [ -f "${PKG_HOME}/debian/watch" ];
        then
            cd $PKG_HOME && uscan --force-download;
        fi
    fi

}

guess_arch(){
        PKG=$1;
        CONTROL="${PKG_HOME}/debian/control";
        ARCH=`grep ^Architecture: ${CONTROL}|sed -s 's,Architecture\: ,,'`;

        echo $ARCH;
}

run_pdebuild(){
###
#
# Averiguamos la arquitectura para elegir al chroot correcto
# y lo ejecutamos.
#
###

    if [ "`guess_arch $PKG`" = "any" ];
    then
        # echo $PWD;
        cd $PKG_HOME && $PDEBUILD -- --basetgz ${CHROOT_HOME}/${CHROOT_AMD64};
    else
        # echo $PWD;
        cd $PKG_HOME && \
            $PDEBUILD -- --basetgz ${CHROOT_HOME}/${CHROOT_AMD64} && \
            $PDEBUILD -- --basetgz ${CHROOT_HOME}/${CHROOT_I386} --debbuildopts -B;
    fi
}

###
#
# Entramos al directorio donde clonamos
#
###

cd $REPO_ROOT;

for param in "$@";
do
    [ "$param" = "clone" ] && git_clone;
    [ "$param" = "build" ] && run_pdebuild;
    [ "$param" = "all" ] && git_clone && run_pdebuild;
done
