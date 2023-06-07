#!/bin/bash

cd $(dirname $0)
CURRENT_DIR=$(pwd)
source ./config.sh

KUBESPRAY_TARBALL=files/kubespray-${KUBESPRAY_VERSION}.tar.gz
DIR=kubespray-${KUBESPRAY_VERSION}

if [ -d $DIR ]; then
    echo "${DIR} already exists."
    exit 0
fi

if [ ! -e $KUBESPRAY_TARBALL ]; then
    echo "$KUBESPRAY_TARBALL does not exist."
    exit 1
fi

tar xvzf $KUBESPRAY_TARBALL || exit 1

# apply patches
sleep 1 # avoid annoying patch error in shared folders.
if [ -d $CURRENT_DIR/patches/${KUBESPRAY_VERSION} ]; then
    for patch in $CURRENT_DIR/patches/${KUBESPRAY_VERSION}/*.patch; do
        if [[ -f "${patch}" ]]; then
          echo "===> Apply patch: $patch"
          (cd $DIR && patch -p1 < $patch)
        fi
    done
fi
