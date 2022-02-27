#!/bin/bash

source config.sh

KUBESPRAY_TARBALL=kubespray-${KUBESPRAY_VERSION}.tar.gz

mkdir -p ./cache

remove_kubespray_cache_dir() {
    if [ ${KUBESPRAY_DIR} = "./cache/kubespray" ] && [ -d ${KUBESPRAY_DIR} ]; then
        /bin/rm -rf ${KUBESPRAY_DIR}
    fi
}

if [ $KUBESPRAY_VERSION == "master" ]; then
    remove_kubespray_cache_dir
    echo "===> Checkout kubespray master"
    if [ ! -d ${KUBESPRAY_DIR} ]; then
        git clone https://github.com/kubernetes-sigs/kubespray.git ${KUBESPRAY_DIR}
    fi
    exit 0
fi


if [ ! -e outputs/files/${KUBESPRAY_TARBALL} ]; then
    echo "===> Download ${KUBESPRAY_TARBALL}"
    mkdir -p outputs/files/
    curl -SL https://github.com/kubernetes-sigs/kubespray/archive/refs/tags/v${KUBESPRAY_VERSION}.tar.gz >outputs/files/${KUBESPRAY_TARBALL} || exit 1

    remove_kubespray_cache_dir
fi

if [ ! -d ${KUBESPRAY_DIR} ]; then
    echo "===> Extract ${KUBESPRAY_TARBALL}"
    tar xzf outputs/files/${KUBESPRAY_TARBALL}

    mv kubespray-${KUBESPRAY_VERSION} ${KUBESPRAY_DIR}
fi
