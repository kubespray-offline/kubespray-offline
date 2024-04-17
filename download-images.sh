#!/bin/bash

source ./config.sh
source scripts/common.sh
source scripts/images.sh

if [ "$SKIP_DOWNLOAD_IMAGES" = "true" ]; then
    exit 0
fi

if [ ! -e "${IMAGES_DIR}/images.list" ]; then
    echo "${IMAGES_DIR}/images.list does not exist. Run download-kubespray-files.sh first."
    exit 1
fi

# download images
images=$(cat ${IMAGES_DIR}/images.list)
for i in $images; do
    get_image $i
done
