#!/bin/bash

if [ $# -ne 1 ]; then
    echo "usage: $0 <target>"
    exit 1
fi
target=$1

OPTS="--build-arg http_proxy=$http_proxy --build-arg https_proxy=$https_proxy"
#OPTS="--progress=plain --no-cache=true"

echo "===> build $target"
docker build -f Dockerfile.$target -t kubespray-offline-$target:latest $OPTS ..
