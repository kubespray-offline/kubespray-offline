#!/bin/bash

source config.sh
source scripts/common.sh
source scripts/images.sh

cp -f ./requirements.txt ./ansible-container/

echo "==> Create ansible container"
(cd ./ansible-container && $sudo make && $sudo make save) || exit 1

cp -f ./ansible-container/kubespray-offline-ansible.tar.gz $IMAGES_DIR/

cp -f ./ansible-container/ansible-container.sh ./outputs/
