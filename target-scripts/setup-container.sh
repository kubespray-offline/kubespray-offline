#!/bin/bash

# install containerd
./install-containerd.sh

# Load images
echo "==> Load registry, nginx images"
NERDCTL=/usr/local/bin/nerdctl
cd ./images

for f in docker.io_library_registry-*.tar.gz docker.io_library_nginx-*.tar.gz; do
    gunzip -c $f | sudo $NERDCTL load
done

if [ -f kubespray-offline-container.tar.gz ]; then
    gunzip -c kubespray-offline-container.tar.gz | sudo $NERDCTL load
fi
