#!/bin/bash

source ./config.sh

LOCAL_REGISTRY=${LOCAL_REGISTRY:-"localhost:${REGISTRY_PORT}"}
NERDCTL=/usr/local/bin/nerdctl

BASEDIR="."
if [ ! -d images ] && [ -d ../outputs ]; then
    BASEDIR="../outputs"  # for tests
fi

load_images() {
    for image in $BASEDIR/images/*.tar.gz; do
        echo "===> Loading $image"
        sudo $NERDCTL load -i $image || exit 1
    done
}

push_images() {
    images=$(cat $BASEDIR/images/*.list)
    for image in $images; do

        # Removes specific repo parts from each image for kubespray
        newImage=$image
        for repo in registry.k8s.io k8s.gcr.io gcr.io ghcr.io docker.io quay.io $ADDITIONAL_CONTAINER_REGISTRY_LIST; do
            newImage=$(echo ${newImage} | sed s@^${repo}/@@)
        done

        newImage=${LOCAL_REGISTRY}/${newImage}

        echo "===> Tag ${image} -> ${newImage}"
        sudo $NERDCTL tag ${image} ${newImage} || exit 1

        echo "===> Push ${newImage}"
        sudo $NERDCTL push ${newImage} || exit 1
    done
}

load_images
push_images
