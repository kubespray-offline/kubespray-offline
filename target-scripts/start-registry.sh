#!/bin/bash

source ./config.sh

REGISTRY_IMAGE=${REGISTRY_IMAGE:-registry:2.7.1}
REGISTRY_DIR=${REGISTRY_DIR:-/var/lib/registry}

if [ ! -e $REGISTRY_DIR ]; then
    sudo mkdir $REGISTRY_DIR
fi

sudo nerdctl run -d \
    -p ${REGISTRY_PORT}:5000 \
    --restart always \
    --name registry \
    -v $REGISTRY_DIR:/var/lib/registry \
    $REGISTRY_IMAGE
