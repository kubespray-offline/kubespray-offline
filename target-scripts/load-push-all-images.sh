#!/bin/bash

LOCAL_REGISTRY=localhost:35000

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
    echo "===> Tag $image"
    sudo docker tag $image ${LOCAL_REGISTRY}/${image}
    echo "===> Push $image"
    sudo docker push ${LOCAL_REGISTRY}/${image}
  done
}

load_images
push_images
