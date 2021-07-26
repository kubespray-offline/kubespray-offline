#!/bin/bash

LOCAL_REGISTRY=${LOCAL_REGISTRY:-"localhost:35000"}

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
    FIRST_PART=$(echo ${image} | awk -F"/" '{print $1}')
    if  [ "$FIRST_PART" = "k8s.gcr.io" ] ||
        [ "$FIRST_PART" = "gcr.io" ] ||
        [ "$FIRST_PART" = "docker.io" ] ||
        [ "$FIRST_PART" = "quay.io" ]; then
        newimage=$(echo ${image} | sed s@"${FIRST_PART}/"@@)
    else
        newimage=$image
    fi

    echo "===> Tag $image -> $newimage"
    sudo docker tag $image ${LOCAL_REGISTRY}/${newimage}

    echo "===> Push $newimage"
    sudo docker push ${LOCAL_REGISTRY}/${newimage}
  done
}

load_images
push_images
