#!/bin/bash

# install containerd
./install-containerd.sh

# Load images
echo "==> Load registry, nginx images"
NERDCTL=/usr/local/bin/nerdctl
cd ./images
gunzip -c docker.io_library_registry-*.tar.gz | sudo $NERDCTL load
gunzip -c docker.io_library_nginx-*.tar.gz | sudo $NERDCTL load

if [ -f kubespray-offline-container.tar.gz ]; then
    gunzip -c kubespray-offline-container.tar.gz | sudo $NERDCTL load
fi
