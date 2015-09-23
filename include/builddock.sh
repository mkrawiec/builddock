set -o nounset
set -o errexit

declare -r PROJECTS=$ROOT/projects

# Download the sources in whatever archive format and repack them into unified
# file $output_filename.tar.gz
download_sources()
{
    local download_url=$1; shift
    local output_filename=$1; shift
    local download_file=${download_url##*/}

    # Save file as tmp with original extension (e.g tmp.zip if zip file)
    curl -L $download_url -o "tmp_$download_file"

    # Repack the downloaded file
    touch tmp_outdir
    atool --save-outdir=tmp_outdir --extract "tmp_$download_file"
    local outdir=$(cat tmp_outdir)
    mv $outdir $output_filename
    apack ${output_filename}.tar.gz $output_filename

    # Mark unpacked directory for deletion by service_cleanup
    mv $output_filename tmp_unpacked_dir
}

# If there is a service hook defined in service.sh run it
run_service_hook()
{
    local signature=$1; shift

    if [ "$(type -t pkg_service_hook)" = 'function' ]; then
        pkg_service_hook
    fi
}

# Run service commands
refresh_service()
{
    local signature=$1; shift
    local name=${signature##*/}

    pushd $PROJECTS/$signature
    source service.sh
    # If download url is set and file does not exist get it
    if [ -n $PKG_DOWNLOAD_URL ] && [ ! -f $name-${PKG_VERSION}.tar.gz ]; then
        download_sources $PKG_DOWNLOAD_URL $name-$PKG_VERSION
    fi

    run_service_hook $signature

    # Update version in .spec file
    sed -i "s/Version:.*/Version: $PKG_VERSION/g" "${name}.spec"
    popd
}

service_cleanup()
{
    local signature=$1; shift

    # Remove project files with tmp_ prefix
    rm -fr $PROJECTS/$signature/tmp_*
}

# Run $cmd in docker container as rpmaker user
run_docker()
{
    local cmd=$1; shift

    docker run \
        -v $ROOT/projects:/home/rpmaker/rpmbuild/_projects \
        --net=host --rm \
        -it mkrawiec/rpmbuild \
        su -c "$cmd" rpmaker
}

# Build package in docker environment
build_package()
{
    local signature=$1; shift

    echo "Starting build for ${signature}..."
    refresh_service $signature
    run_docker "build-package $signature" || true
    service_cleanup $signature
}

# Prepare set of empty files for new package
new_package()
{
    local signature=$1; shift

    mkdir -p $PROJECTS/$signature
    touch $PROJECTS/$signature/service.sh
    touch $PROJECTS/$signature/${signature##*/}.spec

    echo "Generating files for ${signature}... Done"
}

# Push new build result (src.rpm) to git repo
push_build()
{
    local signature=$1; shift

    pushd $PROJECTS/$signature
    git add *.src.rpm
    git commit -m "Build new src.rpm for $signature"
    git push -u origin master
    popd
}

