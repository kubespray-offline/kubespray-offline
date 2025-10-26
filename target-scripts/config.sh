#!/bin/bash
# Kubespray version to download. Use "master" for latest master branch.
KUBESPRAY_VERSION=${KUBESPRAY_VERSION:-2.29.0}
#KUBESPRAY_VERSION=${KUBESPRAY_VERSION:-master}

# Versions of containerd related binaries used in `install-containerd.sh`
# These version must be same as kubespray.
# Refer `roles/kubespray_defaults/vars/main/checksums.yml` of kubespray.
RUNC_VERSION=1.3.2
CONTAINERD_VERSION=2.1.4
NERDCTL_VERSION=2.1.6
CNI_VERSION=1.8.0

# Some container versions, must be same as ../imagelists/images.txt
NGINX_VERSION=1.29.2
REGISTRY_VERSION=2.8.3

# container registry port
REGISTRY_PORT=${REGISTRY_PORT:-35000}

# Additional container registry hosts
ADDITIONAL_CONTAINER_REGISTRY_LIST=${ADDITIONAL_CONTAINER_REGISTRY_LIST:-"myregistry.io"}
