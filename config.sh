#!/bin/bash

# Kubespray version to download. Use "master" for latest master branch.
KUBESPRAY_VERSION=${KUBESPRAY_VERSION:-2.24.1}
#KUBESPRAY_VERSION=${KUBESPRAY_VERSION:-master}

# container runtime for preparation node
container_runtime=docker
#container_runtime=containerd

if [[ "$container_runtime" == "docker" ]]; then
    docker=docker
else
    docker=${docker:-/usr/local/bin/nerdctl}
fi

# Run ansible in container?
ansible_in_container=${ansible_in_container:-false}
