#!/bin/bash

BASEDIR=$(cd $(dirname $0)/..; pwd)
cd $BASEDIR/outputs
source ./config.sh

prepare_servers() {
    #set -x

    # Remove default route
    sudo ip route del default
    
    # prepare
    ./prepare.sh || exit 1

    # start web server
    ./start-nginx.sh || exit 1

    # setup local repositories
    ./setup-offline.sh || exit 1

    # start private registry
    ./start-registry.sh || exit 1

    # load and push all images to registry
    ./load-push-all-images.sh || exit 1

    # remove all images
    images=$(cat images/*.list)
    for image in $images; do
        if ! grep "^nginx" $image >/dev/null && ! grep "^registry" $image >/dev/null; then  # do not remove running nginx/registry image
            echo "==> Remove image: $image"
            sudo nerdctl image rm $image
        fi

        localImage=$image
        for repo in k8s.gcr.io gcr.io docker.io quay.io; do
            localImage=$(echo ${localImage} | sed s@^${repo}/@@)
        done

        echo "==> Remove image: localhost:$REGISTRY_PORT/$localImage"
        sudo nerdctl image rm localhost:$REGISTRY_PORT/$localImage
    done
    #set +x
}

prepare_servers
