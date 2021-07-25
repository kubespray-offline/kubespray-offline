#!/bin/bash

BASEDIR="."
if [ ! -d images ] && [ -d ../outputs ]; then
  BASEDIR="../outputs"  # for tests
fi

# Install docker-ce
if ! command -v docker >/dev/null; then
  if [ -e /etc/redhat-release ]; then
    :
  else
    DEBDIR=$BASEDIR/debs/pkgs
    sudo dpkg -i $DEBDIR/docker-ce*.deb $DEBDIR/containerd*.deb
  fi
fi

# Load images
sudo docker load -i $BASEDIR/images/docker.io-library-registry-*.tar
sudo docker load -i $BASEDIR/images/docker.io-library-nginx-*.tar
