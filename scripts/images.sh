#!/bin/bash

IMAGES_DIR=outputs/images
if [ ! -d $IMAGES_DIR ]; then
    mkdir -p $IMAGES_DIR
fi

get_image() {
    image=$1

    filename="$(echo ${image} | sed s@"/"@"-"@g | sed s/":"/"-"/g)".tar

    if [ ! -e $IMAGES_DIR/$filename ]; then
        echo "==> Pull $image"
        sudo docker pull $image || exit 1

        echo "==> Save $image"
        sudo docker save -o $IMAGES_DIR/$filename $image
        sudo chown $(whoami) $IMAGES_DIR/$filename
        chmod 0644 $IMAGES_DIR/$filename
    else
        echo "==> Skip $image"
    fi
}

#
# Expand container image repo.
# ex)
#   registry:2       => docker.io/library/registry:2
#   rook/ceph:v1.3.2 => docker.io/rook/ceph:v1.3.2
#
expand_image_repo() {
    local repo="$1"

    if [[ "$repo" =~ ^[a-zA-Z0-9]+: ]]; then  # does not contain slash
        repo="docker.io/library/$repo"
    elif [[ "$repo" =~ ^[a-zA-Z0-9]+\/ ]]; then  # does not contain fqdn (period)
            repo="docker.io/$repo"
    fi
    echo "$repo"
}
