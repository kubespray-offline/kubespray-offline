#!/bin/bash
# Kubespray version to download. Use "master" for latest master branch.
KUBESPRAY_VERSION=${KUBESPRAY_VERSION:-2.31.0}
#KUBESPRAY_VERSION=${KUBESPRAY_VERSION:-master}

# Versions of containerd related binaries used in `install-containerd.sh`
# These version must be same as kubespray.
# Refer `roles/kubespray_defaults/vars/main/checksums.yml` of kubespray.
RUNC_VERSION=1.4.2
CONTAINERD_VERSION=2.2.3
NERDCTL_VERSION=2.2.2
CNI_VERSION=1.9.1

# Some container versions, must be same as ../imagelists/images.txt
NGINX_VERSION=1.29.4
REGISTRY_VERSION=3.0.0

# container registry port
REGISTRY_PORT=${REGISTRY_PORT:-35000}

# Additional container registry hosts
ADDITIONAL_CONTAINER_REGISTRY_LIST=${ADDITIONAL_CONTAINER_REGISTRY_LIST:-"myregistry.io"}

# Architecture of binary files
# Detect OS type and get architecture accordingly
map_arch() {
    case "$1" in
        x86_64)
            echo "amd64"
            ;;
        aarch64)
            echo "arm64"
            ;;
        *)
            echo "$1"
            ;;
    esac
}

if [ -e /etc/redhat-release ]; then
    # RHEL/AlmaLinux/Rocky Linux
    ARCH=$(uname -m)
    IMAGE_ARCH=$(map_arch "$ARCH")
elif command -v dpkg >/dev/null 2>&1; then
    # Ubuntu/Debian
    IMAGE_ARCH=$(dpkg --print-architecture)
else
    # Fallback: use uname -m
    ARCH=$(uname -m)
    IMAGE_ARCH=$(map_arch "$ARCH")
fi
