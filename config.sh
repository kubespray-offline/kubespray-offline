#!/bin/bash

# Kubespray directory
# If this directory does not exist, kubespray will be downloaded automatically.
KUBESPRAY_DIR=${KUBESPRAY_DIR:-./cache/kubespray}

# Kubespray version to download. Use "master" for latest master branch.
KUBESPRAY_VERSION=${KUBESPRAY_VERSION:-2.18.0}

# container runtime for preparation node
docker=${docker:-docker}
#docker=${docker:-/usr/local/bin/nerdctl}
