#!/bin/bash

# install containerd
./install-containerd.sh

# Load images
echo "==> Load registry, nginx images"
NERDCTL=/usr/local/bin/nerdctl
cd ./images

for f in docker.io_library_registry-*.tar.gz docker.io_library_nginx-*.tar.gz; do
    sudo $NERDCTL load -i $f || exit 1
done

if [ -f kubespray-offline-container.tar.gz ]; then
    sudo $NERDCTL load -i kubespray-offline-container.tar.gz || exit 1
fi
