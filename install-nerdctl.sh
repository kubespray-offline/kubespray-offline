#!/bin/bash
NERDCTL_VERSION=1.7.1
NERDCTL_TARBALL=nerdctl-${NERDCTL_VERSION}-linux-amd64.tar.gz

if [ ! -x /usr/local/bin/nerctl ]; then
    echo "==> Install nerdctl"
    curl -SLO https://github.com/containerd/nerdctl/releases/download/v${NERDCTL_VERSION}/${NERDCTL_TARBALL} || exit 1
    tar xvf ./${NERDCTL_TARBALL} -C /tmp
    sudo cp /tmp/nerdctl /usr/local/bin
fi
