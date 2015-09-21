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

    new-package)        run-packagectl new-package $2 ;;
    refresh-service)    run-packagectl refresh-service $2 ;;
    quick-build)        run-packagectl quick-build $2 ;;
    build)              run-packagectl build $2 ;;
    all)                run-packagectl all $2 ;;

    thinker)    run-docker /usr/bin/bash ;;
    ed-spec)    $EDITOR rpmbuild/SPECS/${2}.spec ;;
    ed-service) $EDITOR rpmbuild/SOURCES/$2/service.sh ;;

    *)
        echo 'Blah'
        ;;
esac
