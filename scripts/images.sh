#!/bin/bash

IMAGES_DIR=outputs/images
if [ ! -d $IMAGES_DIR ]; then
    mkdir -p $IMAGES_DIR
fi

get_image() {
    image=$1

    tarname="$(echo ${image} | sed s@"/"@"_"@g | sed s/":"/"-"/g)".tar
    zipname="$(echo ${image} | sed s@"/"@"_"@g | sed s/":"/"-"/g)".tar.gz

    if [ ! -e $IMAGES_DIR/$zipname ]; then
        echo "==> Pull $image"

        max_retries=3
        retry_delay=3
        attempt=0
        success=false

        while [ $attempt -lt $max_retries ]; do
            echo $sudo $docker pull $image
            $sudo $docker pull $image && success=true && break
            attempt=$((attempt + 1))
            echo "Attempt $attempt/$max_retries failed. Retrying in $retry_delay seconds..."
            sleep $retry_delay
        done

        if [ "$success" = false ]; then
            echo "Failed to pull $image after $max_retries attempts."
            exit 1
        fi

        echo "==> Save $image"
        echo $sudo $docker save -o $IMAGES_DIR/$tarname $image
        $sudo $docker save -o $IMAGES_DIR/$tarname $image || exit 1
        $sudo chown $(whoami) $IMAGES_DIR/$tarname
        chmod 0644 $IMAGES_DIR/$tarname
        gzip -v $IMAGES_DIR/$tarname
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
