#!/bin/bash

if [ $# -ne 1 ]; then
    echo "usage: $0 <target>"
    exit 1
fi
target=$1

OPTS=""
#OPTS="--progress=plain --no-cache=true"

echo "===> build $targe"
docker build -f Dockerfile.$target -t kubespray-offline-$target:latest $OPTS ..
