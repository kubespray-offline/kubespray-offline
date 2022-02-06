#!/bin/bash

# install containerd
./install-containerd.sh

# Load images
echo "==> Load registry, nginx images"
NERDCTL=/usr/local/bin/nerdctl
cd ./images
gunzip -c docker.io-library-registry-*.tar.gz | sudo $NERDCTL load
gunzip -c docker.io-library-nginx-*.tar.gz | sudo $NERDCTL load
