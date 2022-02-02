#!/bin/bash

# Kubespray directory
# If this directory does not exist, kubespray will be downloaded automatically.
KUBESPRAY_DIR=${KUBESPRAY_DIR:-./kubespray}

# Kubespray version to download
KUBESPRAY_VERSION=2.18.0
KUBESPRAY_TARBALL=kubespray-${KUBESPRAY_VERSION}.tar.gz

# Used in download-kuberspray-files.sh
# These values must be matched as kubespray/roles/kubespray-defaults/defaults/main.yml
containerd_version=1.5.8
snapshot_controller_tag=v4.2.1
