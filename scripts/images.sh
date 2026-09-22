#!/bin/bash

IMAGES_DIR=outputs/images
if [ ! -d $IMAGES_DIR ]; then
    mkdir -p $IMAGES_DIR
fi

get_image() {
    image=$1

    tarname="$(echo "$image" | sed s@"/"@"_"@g | sed s/":"/"-"/g)".tar
    zipname="$(echo "$image" | sed s@"/"@"_"@g | sed s/":"/"-"/g)".tar.gz

    if [ ! -e "$IMAGES_DIR/$zipname" ]; then
        echo "==> Pull & save $image"

        # Remove any leftover tar from a previously interrupted/failed copy.
        # skopeo's docker-archive format refuses to write into an existing
        # file ("doesn't support modifying existing images"), so a stale
        # partial .tar here would make every retry fail at this step.
        rm -f "$IMAGES_DIR/$tarname"

        # skopeo copies straight from the registry to a docker-archive file,
        # with no local container storage/daemon and no root privileges
        # required. --override-arch pins the architecture for multi-arch
        # (manifest list) images, since skopeo otherwise defaults to the
        # build host's own architecture.
        echo skopeo copy --override-arch "$IMAGE_ARCH" --retry-times 3 "docker://$image" "docker-archive:$IMAGES_DIR/$tarname:$image"
        skopeo copy --override-arch "$IMAGE_ARCH" --retry-times 3 "docker://$image" "docker-archive:$IMAGES_DIR/$tarname:$image" || exit 1
        chmod 0644 "$IMAGES_DIR/$tarname"
        gzip -v "$IMAGES_DIR/$tarname"
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
