#!/bin/bash
# Kubespray version to download. Use "master" for latest master branch.
KUBESPRAY_VERSION=${KUBESPRAY_VERSION:-2.25.0}
#KUBESPRAY_VERSION=${KUBESPRAY_VERSION:-master}

# These version must be same as kubespray.
# Refer `roles/kubespray-defaults/defaults/main/download.yml` of kubespray.
RUNC_VERSION=1.1.12
CONTAINERD_VERSION=1.7.16
NERDCTL_VERSION=1.7.4
CNI_VERSION=1.3.0

# container registry port
REGISTRY_PORT=${REGISTRY_PORT:-35000}
