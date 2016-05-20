#!/usr/bin/env python
# usage:
# $ hpkg --clean --update --package pkg-holahuayra
# $ hpkg -cup pkg-holahuayra


import os
import re
import sys
import time
import shlex
import shutil
import argparse
import tempfile
import subprocess as sp
from glob import glob


VERSION = "0.3"
__file = os.path.basename(__file__)
HOME = "/pkg"
BUILD_DIR = tempfile.mkdtemp("-hpkg")
RESULT_ROOT = os.path.join(HOME, "result")
REPO_GITHUB = "http://github.com/HuayraLinux/{}"


def sp_check_output(cmd, shell=True):
    return sp.check_output(shlex.split(cmd), shell)


def sp_Popen(cmd, shell=True,cwd=None):
    output = sp.Popen(cmd, stdin=sp.PIPE, stdout=sp.PIPE, stderr=sp.PIPE, shell=shell, cwd=cwd)
    while output.poll() is None:
        yield output.stdout.readline()


def sp_call(cmd):
    return sp.call(shlex.split(cmd))


def sp_check_call(cmd, cwd=None, wait=True):
    return sp.check_call(shlex.split(cmd), cwd=cwd)


def version():
    "shows the current version"
    print VERSION


def show_help():
    "shows the basic usage"
    print "{} -h".format(__file)


def has_watchfile(package):
    "Looks for a debian/watch file"
    package_root = os.path.join(BUILD_DIR, package)
    watch_file = os.path.join(package_root, "debian", "watch")

    return os.path.isfile(watch_file)


def uscan(package):
    "uses `uscan` to d/l the source code"
    package_root = os.path.join(BUILD_DIR, package)

    sp_check_call("uscan --force-download", cwd=package_root, wait=True)


def git_clone(repo, branch=None):
    "Clone the github repository"
    git_cmd = "git clone {url} {branch}".format(
        url=repo,
        branch="-b {}".format(branch) if branch else ""
    )

    return sp_check_call(git_cmd, cwd=BUILD_DIR)


def parse_changelog(package, field):
    build_package_root = os.path.join(BUILD_DIR, package)

    if not field:
        return ""
    else:
        output = sp_Popen("dpkg-parsechangelog -S{}".format(field),
                          cwd=build_package_root)
        return [re.sub("([\r\n]+)$","", line) for line in output if line]


def extract_upstream(package, n=0):
    "uses pbuilder script to satisfy build-dependencies"
    build_package_root = os.path.join(BUILD_DIR, package)
    source = parse_changelog(package, "Source")[0]
    orig_file = glob(os.path.join(BUILD_DIR, "{}*.orig.tar.gz".format(source)))
    if orig_file:
        orig_file = orig_file[0]
        sp_check_call("tar xzvf {} -C {} --strip 1".format(orig_file, build_package_root), cwd=BUILD_DIR)


def install_dependencies(package):
    "uses pbuilder script to satisfy build-dependencies"
    package_root = os.path.join(BUILD_DIR, package)
    control_file = os.path.join(package_root, "debian", "control")

    sp_call("/usr/lib/pbuilder/pbuilder-satisfydepends-classic --control {}".format(control_file))


def dpkg_buildpackage(package, flags=""):
    build_package_root = os.path.join(BUILD_DIR, package)

    sp_check_call("dpkg-buildpackage {}".format(flags), cwd=build_package_root)


def get_architecture():
    output = sp_Popen("dpkg --print-architecture")
    return [re.sub("([\r\n]+)$","", line) for line in output if line]


def copy_result(package):
    match_line = lambda l: \
                 re.search("(?P<checksum>\w+) (?P<size>\d+) (?P<section>\w+) (?P<priority>\w+) (?P<file>.*)", l)
    build_package_root = os.path.join(BUILD_DIR, package)

    source = parse_changelog(package, "Source")[0]
    version = parse_changelog(package, "Version")[0]
    arch = get_architecture()[0]
    changes = "{}_{}_{}.changes".format(source, version, arch)
    changes_file = os.path.join(BUILD_DIR, changes)

    if os.path.isfile(changes_file):
        files = [line.group('file') for line in
                 filter(lambda l: l,
                        map(match_line,
                            open(changes_file,"r").readlines()))]

        for filename in files + [changes]:
            shutil.copy(os.path.join(BUILD_DIR, filename),
                        os.path.join(RESULT_ROOT, filename))

    return None


def apt_update():
    sp_call("apt-get update")


def clean(package):
    package_root = os.path.join(BUILD_DIR, package)

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

        # copy result
        copy_result(package)

    return None


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('-v', '--version',
                        action="store_true",
                        help=version.__doc__)
    parser.add_argument('-p', '--package',
                        type=unicode,
                        help="Github repo of the Package to be built")
    parser.add_argument('-u', '--update',
                        action="store_true",
                        help="Update Apt repositories")
    parser.add_argument('-c', '--clean',
                        action="store_true",
                        help="Remove built files")

    args = parser.parse_args()


    if args.package:
        if args.clean:
           clean(args.package)
        if args.update:
            apt_update()

        build_package(args.package)
    else:
        show_help()
