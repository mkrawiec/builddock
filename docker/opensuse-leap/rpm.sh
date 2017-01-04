#!/usr/bin/env bash
# Build rpm inside docker container
# ENV TARGET_NAME target name
# ENV TARGET_BDEP build dep command

set -o nounset
set -o errexit

declare -r PROJ_DIR="$HOME/_project"

rpm_mk_symlinks()
{
    # Symlink .spec file
    pushd SPECS/
    ln -s $PROJ_DIR/*.spec .
    popd

    # Symlink source files
    pushd SOURCES/
    find $PROJ_DIR -maxdepth 1 -type f \
        -not -name 'tmp_*' \
        -not -name 'service.sh' \
        -not -name '*.spec' \
        -exec ln -s {} . \;
    popd
}

rpm_run_hook()
{
    source $PROJ_DIR/service.sh
    if [ "$(type -t pkg_prebuild_hook)" = 'function' ]; then
        pkg_prebuild_hook
    fi
}

rpm_build()
{
    pushd SPECS
    sudo $TARGET_BDEP *.spec
    rpmbuild -ba *.spec
    popd
}

rpm_copy_results()
{
    # First clean output dir from previous builds
    rm -fr $PROJ_DIR/out; mkdir $PROJ_DIR/out

    cp {SRPMS,RPMS/**}/*.rpm $PROJ_DIR/out
}

mkdir -p $HOME/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
cd $HOME/rpmbuild

rpm_mk_symlinks
rpm_run_hook
rpm_build
rpm_copy_results

