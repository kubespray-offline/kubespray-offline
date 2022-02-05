#!/bin/bash

OPTS=""
#OPTS="--progress=plain --no-cache=true"

for i in alma8 ubuntu2004; do
    echo "===> build $i"
    docker build -f Dockerfile.$i -t kubespray-offline-$i:latest $OPTS ..
done
