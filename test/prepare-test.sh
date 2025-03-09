#!/bin/bash

BASEDIR=$(cd $(dirname $0)/..; pwd)
TESTDIR=$BASEDIR/test

# Go to outputs dir
cd $BASEDIR/outputs
source ./config.sh

NERDCTL=/usr/local/bin/nerdctl

prepare_ssh_key() {
    if [ ! -e ~/.ssh/id_rsa ]; then
        ssh-keygen -f ~/.ssh/id_rsa -N "" && cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
    fi
}

prepare_servers() {
    #set -x

    # Remove default route to emulate offline
    $TESTDIR/go-offline.sh

    # setup
    ./setup-all.sh || exit 1

    # Restore default route
    $TESTDIR/restore-offline.sh

    # remove all images
    images=$(cat images/*.list)
    for image in $images; do
        if ! grep "^nginx" $image >/dev/null && ! grep "^registry" $image >/dev/null; then  # do not remove running nginx/registry image
            echo "==> Remove image: $image"
            sudo $NERDCTL image rm $image
        fi

        localImage=$image
        for repo in registry.k8s.io k8s.gcr.io gcr.io docker.io quay.io; do
            localImage=$(echo ${localImage} | sed s@^${repo}/@@)
        done

        echo "==> Remove image: localhost:$REGISTRY_PORT/$localImage"
        sudo $NERDCTL image rm localhost:$REGISTRY_PORT/$localImage
    done
    #set +x
}

prepare_ssh_key
prepare_servers
