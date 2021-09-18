#!/bin/bash

# Kubespray directory
# If this directory does not exist, kubespray will be downloaded automatically.
KUBESPRAY_DIR=${KUBESPRAY_DIR:-./kubespray}

# Kubespray version to download
KUBESPRAY_VERSION=2.17.0
KUBESPRAY_TARBALL=kubespray-${KUBESPRAY_VERSION}.tar.gz
