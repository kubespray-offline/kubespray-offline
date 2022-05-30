#!/bin/bash

source config.sh
source scripts/common.sh
source scripts/images.sh

KUBESPRAY_DIR=./cache/kubespray-${KUBESPRAY_VERSION}
if [ ! -e $KUBESPRAY_DIR ]; then
    echo "No kubespray dir at $KUBESPRAY_DIR"
    exit 1
fi

cp -f $KUBESPRAY_DIR/requirements.txt ./ansible-container/

echo "==> Create ansible container"
(cd ./ansible-container && $sudo make && $sudo make save) || exit 1

cp -f ./ansible-container/kubespray-offline-ansible.tar.gz $IMAGES_DIR/

cp -f ./ansible-container/ansible-container.sh ./outputs/
