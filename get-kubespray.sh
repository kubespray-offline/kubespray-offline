#!/bin/bash

CURRENT_DIR=$(cd $(dirname $0); pwd)
source config.sh

KUBESPRAY_TARBALL=kubespray-${KUBESPRAY_VERSION}.tar.gz

KUBESPRAY_DIR=./cache/kubespray-${KUBESPRAY_VERSION}

mkdir -p ./cache
mkdir -p outputs/files/

remove_kubespray_cache_dir() {
    if [ -e ${KUBESPRAY_DIR} ]; then
        /bin/rm -rf ${KUBESPRAY_DIR}
    fi
}

if [ $KUBESPRAY_VERSION == "master" ] || [[ $KUBESPRAY_VERSION =~ ^release- ]]; then
    remove_kubespray_cache_dir
    echo "===> Checkout kubespray branch : $KUBESPRAY_VERSION"
    if [ ! -e ${KUBESPRAY_DIR} ]; then
        git clone -b $KUBESPRAY_VERSION https://github.com/kubernetes-sigs/kubespray.git ${KUBESPRAY_DIR}
        tar czf outputs/files/${KUBESPRAY_TARBALL} -C ./cache kubespray-${KUBESPRAY_VERSION}
    fi
    exit 0
fi


if [ ! -e outputs/files/${KUBESPRAY_TARBALL} ]; then
    echo "===> Download ${KUBESPRAY_TARBALL}"
    curl -SL https://github.com/kubernetes-sigs/kubespray/archive/refs/tags/v${KUBESPRAY_VERSION}.tar.gz >outputs/files/${KUBESPRAY_TARBALL} || exit 1

    remove_kubespray_cache_dir
fi

if [ ! -e ${KUBESPRAY_DIR} ]; then
    echo "===> Extract ${KUBESPRAY_TARBALL}"
    tar xzf outputs/files/${KUBESPRAY_TARBALL}

    mv kubespray-${KUBESPRAY_VERSION} ${KUBESPRAY_DIR}

    sleep 1  # ad hoc, for vagrant shared directory

    # Apply patches
    patch_dir=${CURRENT_DIR}/target-scripts/patches/${KUBESPRAY_VERSION}
    if [ -d $patch_dir ]; then
        for patch in ${patch_dir}/*.patch; do
            echo "===> Apply patch $patch"
            (cd $KUBESPRAY_DIR && patch -p1 < $patch) || exit 1
        done
    fi
fi

echo "Done."
