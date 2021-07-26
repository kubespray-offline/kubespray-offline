#!/bin/bash

KUBESPRAY_VERSION=2.16.0
KUBESPRAY_TARBALL=kubespray-${KUBESPRAY_VERSION}.tar.gz

KUBESPRAY_DIR=${KUBESPRAY_DIR:-./kubespray}

if [ ! -d ${KUBESPRAY_DIR} ]; then
    if [ ! -e ${KUBESPRAY_TARBALL} ]; then
        echo "===> Download ${KUBESPRAY_TARBALL}"
        curl -SL https://github.com/kubernetes-sigs/kubespray/archive/refs/tags/v${KUBESPRAY_VERSION}.tar.gz >${KUBESPRAY_TARBALL} || exit 1
    fi
    echo "===> Extract ${KUBESPRAY_TARBALL}"
    tar xzf ${KUBESPRAY_TARBALL}

    mv kubespray-${KUBESPRAY_VERSION} ${KUBESPRAY_DIR}
fi
