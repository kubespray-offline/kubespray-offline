#!/bin/bash

source ./config.sh

REGISTRY_IMAGE=registry:${REGISTRY_VERSION}
REGISTRY_DIR=${REGISTRY_DIR:-/var/lib/registry}

if [ ! -e $REGISTRY_DIR ]; then
    sudo mkdir $REGISTRY_DIR
fi

echo "===> Start registry"
sudo /usr/local/bin/nerdctl run -d \
    --network host \
    -e REGISTRY_HTTP_ADDR=0.0.0.0:${REGISTRY_PORT} \
    --restart always \
    --name registry \
    -v $REGISTRY_DIR:/var/lib/registry \
    $REGISTRY_IMAGE || exit 1
