#!/bin/bash

source config.sh

if [ ! -e outputs/${KUBESPRAY_TARBALL} ]; then
    echo "===> Download ${KUBESPRAY_TARBALL}"
    curl -SL https://github.com/kubernetes-sigs/kubespray/archive/refs/tags/v${KUBESPRAY_VERSION}.tar.gz >outputs/${KUBESPRAY_TARBALL} || exit 1
fi

if [ ! -d ${KUBESPRAY_DIR} ]; then
    echo "===> Extract ${KUBESPRAY_TARBALL}"
    tar xzf outputs/${KUBESPRAY_TARBALL}

    mv kubespray-${KUBESPRAY_VERSION} ${KUBESPRAY_DIR}
fi
