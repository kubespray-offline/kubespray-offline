#!/bin/bash

# Kubespray version to download. Use "master" for latest master branch.
KUBESPRAY_VERSION=${KUBESPRAY_VERSION:-2.18.1}

# container runtime for preparation node
docker=${docker:-docker}
#docker=${docker:-/usr/local/bin/nerdctl}
