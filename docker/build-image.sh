#!/bin/bash

cd $(dirname $0)

push=false
if [ "$1" == "--push" ]; then
    push=true
    shift
fi

if [ $# -ne 1 ]; then
    echo "usage: $0 <target>"
    exit 1
fi
target=$1

OPTS="--progress=plain --no-cache=true"
#OPTS="--build-arg http_proxy=$http_proxy --build-arg https_proxy=$https_proxy"

echo "===> build $target"
docker build -f Dockerfile.$target -t tmurakam/kubespray-offline-$target:latest $OPTS .. || exit 1

if $push; then
    echo "===> push $target"
    docker push tmurakam/kubespray-offline-$target:latest
fi
