#!/bin/bash

source ./config.sh

REGISTRY_IMAGE=registry:${REGISTRY_VERSION}
REGISTRY_DIR=${REGISTRY_DIR:-/var/lib/registry}
NERDCTL="sudo /usr/local/bin/nerdctl --namespace default"

if [ ! -e $REGISTRY_DIR ]; then
    sudo mkdir $REGISTRY_DIR
fi

echo "===> Stop registry"
$NERDCTL container update --restart no registry 2>/dev/null
$NERDCTL container stop registry 2>/dev/null
$NERDCTL container rm registry 2>/dev/null

echo "===> Start registry"
$NERDCTL run -d \
    --network host \
    -e REGISTRY_HTTP_ADDR=0.0.0.0:${REGISTRY_PORT} \
    --restart always \
    --name registry \
    -v $REGISTRY_DIR:/var/lib/registry \
    $REGISTRY_IMAGE || exit 1
