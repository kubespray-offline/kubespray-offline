#!/bin/bash

# Kubespray directory
# If this directory does not exist, kubespray will be downloaded automatically.
KUBESPRAY_DIR=${KUBESPRAY_DIR:-./cache/kubespray}

# Kubespray version to download. Use "master" for latest master branch.
KUBESPRAY_VERSION=${KUBESPRAY_VERSION:-2.18.0}

# Used in download-kuberspray-files.sh (only for kubespray 2.18.0)
# These values must be matched as kubespray/roles/kubespray-defaults/defaults/main.yml
containerd_version=1.5.8
snapshot_controller_tag=v4.2.1

# container runtime for preparation node
docker=${docker:-docker}
#docker=${docker:-/usr/local/bin/nerdctl}
