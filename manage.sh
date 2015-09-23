#!/usr/bin/env bash

declare -r ROOT=$(dirname $(readlink -f $0))

source $ROOT/include/builddock.sh

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

