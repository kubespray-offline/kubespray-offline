#!/bin/bash

source ./config.sh

LOCAL_REGISTRY=${LOCAL_REGISTRY:-"localhost:${REGISTRY_PORT}"}

BASEDIR="."
if [ ! -d images ] && [ -d ../outputs ]; then
  BASEDIR="../outputs"  # for tests
fi

load_images() {
  for image in $BASEDIR/images/*.tar; do
    echo "===> Loading $image"
    sudo docker load -i $image
  done
}

push_images() {
  images=$(cat $BASEDIR/images/*.list)
  for image in $images; do

    # Removes specific repo parts from each image for kubespray
    newImage=$image
    for repo in k8s.gcr.io gcr.io docker.io quay.io; do
        newImage=$(echo ${newImage} | sed s@^${repo}/@@)
    done

    newImage=${LOCAL_REGISTRY}/${newImage}

    echo "===> Tag ${image} -> ${newImage}"
    sudo docker tag ${image} ${newImage}

    echo "===> Push ${newImage}"
    sudo docker push ${newImage}
  done
}

load_images
push_images
