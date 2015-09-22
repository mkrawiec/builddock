#!/usr/bin/env bash

ROOT=$(dirname $(readlink -f $0))

run_docker()
{
    local app=$1; shift

    docker run \
        -v $ROOT/rpmbuild:/home/rpmaker/rpmbuild \
        -v $ROOT/projects:/home/rpmaker/rpmbuild/_projects \
        --net=host --rm \
        -it mkrawiec/rpmbuild \
        su -c "$app" rpmaker
}

# Prepare set of empty files for new package
new_package()
{
    local signature=$1; shift

    mkdir -p $ROOT/projects/$signature
    touch $ROOT/projects/$signature/service.sh
    touch $ROOT/projects/$signature/${signature##*/}.spec

    echo "Generating files for ${signature}... Done"
}

# Build package in docker environment
build_package()
{
    local signature=$1; shift

    echo "Starting build for ${signature}..."
    run_docker "build-package $signature"
}

# Push new build result (src.rpm) to git repo
push_build()
{
    local signature=$1; shift

    pushd $ROOT/projects/$signature
    git add *.src.rpm
    git commit -m "Build new src.rpm for $signature"
    git push -u origin master
    popd
}

case $1 in
    build-image)    docker build -t mkrawiec/rpmbuild docker/ ;;
    build)          build_package $2 ;;
    push-build)     push_build $2 ;;
    new-package)    new_package $2 ;;
    thinker)        run_docker /usr/bin/bash ;;
    ed-spec)        vim projects/$2/${2##*/}.spec ;;
    ed-service)     vim projects/$2/service.sh;;
    *)              echo 'Blah' ;;
esac

