#!/bin/bash

BASEDIR=$(cd $(dirname $0)/..; pwd)
cd $BASEDIR/outputs
source ./config.sh

NERDCTL=/usr/local/bin/nerdctl

prepare_servers() {
    #set -x

    # Remove default route
    sudo ip route del default
    
    # setup
    ./setup-all.sh || exit 1

    # remove all images
    images=$(cat images/*.list)
    for image in $images; do
        if ! grep "^nginx" $image >/dev/null && ! grep "^registry" $image >/dev/null; then  # do not remove running nginx/registry image
            echo "==> Remove image: $image"
            sudo $NERDCTL image rm $image
        fi

        localImage=$image
        for repo in k8s.gcr.io gcr.io docker.io quay.io; do
            localImage=$(echo ${localImage} | sed s@^${repo}/@@)
        done

        echo "==> Remove image: localhost:$REGISTRY_PORT/$localImage"
        sudo $NERDCTL image rm localhost:$REGISTRY_PORT/$localImage
    done
    #set +x
}

prepare_servers
