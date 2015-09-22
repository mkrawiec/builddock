#!/usr/bin/env bash

set -o nounset
set -o errexit

#ROOT=$(dirname $(readlink -f $0))
ROOT=/home/rpmaker/rpmbuild
SOURCES="$ROOT/SOURCES"
SPECS="$ROOT/SPECS"

# Prepare set of empty files for new package
new_package()
{
    local name=$1; shift

    mkdir "$SOURCES/$name/"
    touch "$SOURCES/${name}/service.sh"
    touch "$SPECS/${name}.spec"

    echo "Generating files for ${name}... Done"
}

# Download the pristine sources and repack them into proper archive that can be
# used in .spec file
download_sources()
{
    local download_url=$1; shift
    local download_file=${download_url##*/}
    local output_filename=$1; shift

    rm -f $output_filename.tar.gz

    # save file as tmp with original extension (e.g tmp.zip if zip file)
    curl -L $download_url -o $download_file

    # repack the downloaded file
    touch outdir
    atool --save-outdir=outdir --extract $download_file
    local outdir=$(cat outdir)
    mv $outdir $output_filename
    rm outdir
    apack ${output_filename}.tar.gz $output_filename

    # remove unpacked dir and original download
    rm -fr $output_filename
    rm $download_file
}

# Populate rpmbuild dir with data from service.sh
refresh_service()
{
    local name=$1; shift

    # fetch sources into $name-$version.tar.gz
    pushd "$SOURCES/$name"
    source service.sh
    if [ -n $PKG_DOWNLOAD_URL ]; then
        download_sources $PKG_DOWNLOAD_URL $name-$PKG_VERSION
    fi
    popd

    pushd $SOURCES
    # If there are any broken symlinks to sources delete them
    find -L . -type l -delete

    # Make fresh symlinks to source files
    for file in $(ls --ignore=service.sh "$SOURCES/$name"); do
        ln -fs ./$name/$file $file
    done
    popd

    # Update version in .spec file
    sed -i "s/Version:.*/Version: $PKG_VERSION/g" "$SPECS/${name}.spec"
}

# Build a package without refreshing the service
quick_build()
{
    local name=$1; shift
    pushd "$SPECS"
    sudo dnf -y builddep ${name}.spec
    rpmbuild -ba "${name}.spec"
    popd
}

# Full build with service refresh
build()
{
    local name=$1; shift
    refresh_service $name
    quick_build $name
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
        new-package)        new_package $argv ;;
        refresh-service)    refresh_service $argv ;;
        quick-build)        quick_build $argv ;;
        build)              build $argv ;;
        all)                all ;;
    esac
}

main $@
