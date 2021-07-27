#!/bin/bash

echo "==> Pull additional container images"

source scripts/images.sh

cat imagelists/*.txt | sed "s/#.*$//g" | sort -u > $IMAGES_DIR/additional-images.list
cat $IMAGES_DIR/additional-images.list

IMAGES=$(cat $IMAGES_DIR/additional-images.list)

for image in $IMAGES; do
    image=$(expand_image_repo $image)
    get_image $image
done

