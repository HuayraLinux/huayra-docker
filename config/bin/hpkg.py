#!/usr/bin/env python
# usage:
# $ hpkg --clean --package pkg-holahuayra

import os
import re
import sys
import shlex
import argparse
import subprocess as sp
from glob import glob

VERSION = "0.3"
__file = os.path.basename(__file__)
HOME = "/pkg"
REPO_ROOT = os.path.join(HOME, "repos")
REPO_GITHUB = "http://github.com/HuayraLinux/{}"


def sp_call(cmd):
    return sp.call(shlex.split(cmd))


def sp_check_call(cmd, cwd=None):
    return sp.check_call(shlex.split(cmd), cwd=cwd)


def version():
    "shows the current version"
    print VERSION


def show_help():
    "shows the basic usage"
    print "{} -h".format(__file)


def has_watchfile(package):
    "Looks for a debian/watch file"
    package_root = os.path.join(REPO_ROOT, package)
    watch_file = os.path.join(package_root, "debian", "watch")
    return os.path.isfile(watch_file)


def uscan(package):
    "uses `uscan` to d/l the source code"
    package_root = os.path.join(REPO_ROOT, package)
    sp_check_call("uscan --force-download", cwd=package_root)


def git_clone(repo, branch=None):
    "Clone the github repository"
    git_cmd = "git clone {url} {branch}".format(
        url=repo,
        branch="-b {}".format(branch) if branch else ""
    )
    return sp_check_call(git_cmd, cwd=REPO_ROOT)


def extract_upstream(package):
    "uses pbuilder script to satisfy build-dependencies"
    build_package_root = os.path.join(REPO_ROOT, "build-{}".format(package))
    dsc_file = glob(os.path.join(REPO_ROOT, "*.dsc"))
    print ".dsc files available:", dsc_file
    if dsc_file:
        dsc_file = dsc_file[0]
        sp_check_call("dpkg-source -x {} {}".format(dsc_file, build_package_root), cwd=REPO_ROOT)


def install_dependencies(package):
    "uses pbuilder script to satisfy build-dependencies"
    package_root = os.path.join(REPO_ROOT, package)
    control_file = os.path.join(package_root, "debian", "control")
    sp_call("/usr/lib/pbuilder/pbuilder-satisfydepends-classic --control {}".format(control_file))


def dpkg_buildpackage(package, flags=""):
    build_package_root = os.path.join(REPO_ROOT,"build-{}".format(package))
    if not os.path.isdir(build_package_root):
        build_package_root = os.path.join(REPO_ROOT, package)

    sp_check_call("dpkg-buildpackage {}".format(flags), cwd=build_package_root)


def apt_update():
    sp_call("apt-get update")


def clean(package):
    package_root = os.path.join(REPO_ROOT, package)
    sp_call("rm -fr {}".format(package_root))


def build_package(package):
    """
    - clone the repo
    - has watch file? if so, uses `uscan`
    - install build-dependencies
    - dpkg-buildpackage
    """
    clone = git_clone(REPO_GITHUB.format(package))
    if int(clone) == 0:
        # update repos
        apt_update()

        # try to download upstream's code
        watch_file = has_watchfile(package)
        if watch_file:
            # d/l it with uscan
            uscan(package)

            # extract upstream' code
            extract_upstream(package)

        # install build-dependencies
        install_dependencies(package)

        # build package!
        dpkg_buildpackage(package)

    return ""


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('-v', '--version',
                        action="store_true",
                        help=version.__doc__)
    parser.add_argument('-p', '--package',
                        type=unicode,
                        help="Github repo of the Package to be built")
    parser.add_argument('-c', '--clean',
                        action="store_true",
                        help="Remove built files")

    args = parser.parse_args()

    if args.package:
        if args.clean:
           clean(args.package)
        build_package(args.package)
    else:
        show_help()
