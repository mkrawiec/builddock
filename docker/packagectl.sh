#!/usr/bin/env bash

set -o nounset
set -o errexit

#ROOT=$(dirname $(readlink -f $0))
ROOT=/home/rpmaker/rpmbuild
SOURCES="$ROOT/SOURCES"
SPECS="$ROOT/SPECS"

# Prepare set of empty files for new package
new()
{
    local name=$1; shift

    mkdir "$SOURCES/$name/"
    touch "$SOURCES/${name}/service.sh"
    touch "$SPECS/${name}.spec"

    echo "Generated files for $name"
}

# Pull source, set version (specified in service.sh) and install dependencies
fetch()
{
    local name=$1; shift

    pushd "$SOURCES/$name"
    source service.sh
    if [ -n $PKG_DOWNLOAD_URL ]; then
        curl -O $PKG_DOWNLOAD_URL
    fi

    for file in $(ls --ignore=service.sh "$SOURCES/$name"); do
        stow $file
    done
    popd

    sed -i "s/Version:.*/Version: $PKG_VERSION/g" "$SPECS/${name}.spec"
    sudo dnf builddep $name
}

# Build a package
build()
{
    local name=$1; shift
    pushd "$SPESCS"
    rpmbuild -ba "${name}.spec"
    popd
}

# Fetch & build all packages
all()
{
    echo 'TODO'
}

main()
{
    local action=$1; shift
    local argv=$@

    case $action in
        new)    new $argv ;;
        fetch)  fetch $argv ;;
        build)  build $argv ;;
        all)    all ;;
    esac
}

main $@
