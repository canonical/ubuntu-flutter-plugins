#!/bin/bash

set -eux

url="https://gitlab.gnome.org/GNOME/libhandy.git"

ref=${1:?"Usage: $(basename ${BASH_SOURCE:0}) <ref>"}
libhandy="$(realpath $(dirname ${BASH_SOURCE:0}))/src"
repo="$(realpath ${libhandy/\/packages\/*//packages}/..)" # parent of "packages"
prefix="${libhandy/$repo\//}"

if [ ! -d "$libhandy" ]; then
    # git -C /path/to/ubuntu-flutter-plugins subtree add \
    #     --prefix packages/handy_window/linux/libhandy/src 1.2.3 --squash
    git -C "$repo" subtree add --prefix "$prefix" "$url" "$ref" --squash
else
    # git -C /path/to/ubuntu-flutter-plugins subtree pull \
    #     --prefix packages/handy_window/linux/libhandy/src 1.2.3 --squash
    git -C "$repo" subtree pull --prefix "$prefix" "$url" "$ref" --squash
fi

if ! meson --version > /dev/null 2>&1; then
    echo "ERROR: install meson"
    exit 1
fi

if ! ninja --version > /dev/null 2>&1; then
    echo "ERROR: install ninja-build"
    exit 1
fi

cd "$libhandy"
git -C ../build clean -xdf
meson ../build -Dexamples=false -Dtests=false -Dvapi=false -Dintrospection=disabled
ninja -C ../build
git status
