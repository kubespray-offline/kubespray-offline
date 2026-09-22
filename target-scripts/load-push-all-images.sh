#!/bin/bash

source ./config.sh

LOCAL_REGISTRY=${LOCAL_REGISTRY:-"localhost:${REGISTRY_PORT}"}

# skopeo isn't fetched as a binary like containerd/nerdctl, so install it
# from the local offline repo set up by setup-offline.sh (must run before
# this script, as it does in setup-all.sh).
if ! command -v skopeo >/dev/null 2>&1; then
    echo "===> Install skopeo"
    if [ -e /etc/redhat-release ]; then
        sudo dnf install -y skopeo || exit 1
    else
        sudo apt install -y skopeo || exit 1
    fi
fi

BASEDIR="."
if [ ! -d images ] && [ -d ../outputs ]; then
    BASEDIR="../outputs"  # for tests
fi

#
# Expand container image repo. Must match scripts/images.sh on the download
# side, since that's what decided each image's saved tar filename.
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

push_images() {
    images=$(cat $BASEDIR/images/*.list)
    for image in $images; do
        image=$(expand_image_repo "$image")

        tarname="$(echo "$image" | sed s@"/"@"_"@g | sed s/":"/"-"/g)".tar.gz
        tarfile="$BASEDIR/images/$tarname"
        if [ ! -e "$tarfile" ]; then
            echo "Image archive not found: $tarfile"
            exit 1
        fi

        # Removes specific repo parts from each image for kubespray
        newImage=$image
        for repo in registry.k8s.io k8s.gcr.io gcr.io ghcr.io docker.io quay.io $ADDITIONAL_CONTAINER_REGISTRY_LIST; do
            newImage=$(echo ${newImage} | sed s@^${repo}/@@)
        done

        newImage=${LOCAL_REGISTRY}/${newImage}

        # skopeo copies straight from the tar.gz archive to the registry, no
        # containerd/nerdctl local storage round-trip (load+tag+push) needed,
        # and no root privileges required. The registry is plain HTTP.
        echo "===> Push ${tarfile} -> ${newImage}"
        skopeo copy --dest-tls-verify=false \
            "docker-archive:${tarfile}:${image}" \
            "docker://${newImage}" || exit 1
    done
}

push_images
