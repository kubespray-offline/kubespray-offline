#!/bin/bash

if [ ! -e files ]; then
    mkdir -p files
fi

# download files, if not found
download() {
    url=$1
    filename=$(basename $1)
    if [ ! -e ./files/$filename ]; then
        echo "==> download $url"
        (cd ./files/ && curl -SLO $1)
    fi
}

RUNC_VERSION=1.0.3
CONTAINERD_VERSION=1.5.8
NERDCTL_VERSION=0.15.0
CNI_VERSION=1.0.1

download https://github.com/opencontainers/runc/releases/download/v${RUNC_VERSION}/runc.amd64
download https://github.com/containerd/containerd/releases/download/v${CONTAINERD_VERSION}/containerd-${CONTAINERD_VERSION}-linux-amd64.tar.gz
download https://github.com/containerd/nerdctl/releases/download/v${NERDCTL_VERSION}/nerdctl-${NERDCTL_VERSION}-linux-amd64.tar.gz
download https://github.com/containernetworking/plugins/releases/download/v${CNI_VERSION}/cni-plugins-linux-amd64-v${CNI_VERSION}.tgz

# Install runc
echo "==> Install runc"
sudo cp ./files/runc.amd64 /usr/local/bin/runc
sudo chmod 755 /usr/local/bin/runc

# Install nerdctl
echo "==> Install nerdctl"
tar xvf ./files/nerdctl-*.tar.gz -C /tmp
sudo cp /tmp/nerdctl /usr/local/bin

# Install containerd
echo "==> Install containerd"
sudo tar xvf ./files/containerd-*.tar.gz --strip-components=1 -C /usr/local/bin
sudo cp ./containerd.service /etc/systemd/system/

sudo mkdir -p \
     /etc/systemd/system/containerd.service.d \
     /etc/containerd \
     /var/lib/containerd \
     /run/containerd

sudo cp config.toml /etc/containerd/

echo "==> Start containerd"
sudo systemctl daemon-reload
sudo systemctl enable --now containerd

# Install cni plugins
echo "==> Install CNI plugins"
sudo mkdir -p /opt/cni/bin
sudo tar xvzf ./files/kubernetes/cni/cni-plugins-*.tgz -C /opt/cni/bin
