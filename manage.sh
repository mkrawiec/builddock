#!/usr/bin/env bash

ROOT=$(dirname $(readlink -f $0))

run-docker()
{
    local app=$1; shift

    docker run \
        -v $ROOT/rpmbuild:/home/rpmaker/rpmbuild \
        --net=host --rm \
        -it mkrawiec/rpmbuild \
        su -c "$app" rpmaker
}

run-packagectl()
{
    local action=$1; shift
    local package=$1; shift

    run-docker "/packagectl.sh $action $package"
}

case $1 in
    build-image)
        docker build -t mkrawiec/rpmbuild docker/
        ;;
    new)
        run-packagectl new $2
        ;;
    fetch)
        run-packagectl fetch $2
        ;;
    build)
        run-packagectl build $2
        ;;
    all)
        run-packagectl all $2
        ;;
    thinker)
        run-docker /usr/bin/bash
        ;;
    *)
        echo 'Blah'
        ;;
esac
