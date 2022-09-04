#!/bin/bash

source ./config.sh

ENABLE_DOWNLOAD=${ENABLE_DOWNLOAD:-false}

if [ ! -e files ]; then
    mkdir -p files
fi

# download files, if not found
download() {
    url=$1
    dir=$2

    filename=$(basename $1)
    mkdir -p ./files/$dir

    if [ ! -e ./files/$dir/$filename ]; then
        echo "==> download $url"
        (cd ./files/$dir && curl -SLO $1)
    fi
}

NERDCTL_TARBALL=nerdctl-${NERDCTL_VERSION}-linux-amd64.tar.gz
CONTAINERD_TARBALL=containerd-${CONTAINERD_VERSION}-linux-amd64.tar.gz
CNI_TARBALL=cni-plugins-linux-amd64-v${CNI_VERSION}.tgz

if $ENABLE_DOWNLOAD; then
    download https://github.com/opencontainers/runc/releases/download/v${RUNC_VERSION}/runc.amd64 runc/v${RUNC_VERSION}
    download https://github.com/containerd/containerd/releases/download/v${CONTAINERD_VERSION}/${CONTAINERD_TARBALL}
    download https://github.com/containerd/nerdctl/releases/download/v${NERDCTL_VERSION}/${NERDCTL_TARBALL}
    download https://github.com/containernetworking/plugins/releases/download/v${CNI_VERSION}/${CNI_TARBALL} kubernetes/cni
fi

#select_latest() {
#    local latest=$(ls $* | tail -1)
#    if [ -z "$latest" ]; then
#        echo "No such file: $*"
#        exit 1
#    fi
#    echo $latest
#}

# Install runc
echo "==> Install runc"
sudo cp ./files/runc/v${RUNC_VERSION}/runc.amd64 /usr/local/bin/runc
sudo chmod 755 /usr/local/bin/runc

# Install nerdctl
echo "==> Install nerdctl"
#tar xvf $(select_latest "./files/nerdctl-*.tar.gz") -C /tmp
tar xvf ./files/${NERDCTL_TARBALL} -C /tmp
sudo cp /tmp/nerdctl /usr/local/bin

# Install containerd
echo "==> Install containerd"
sudo tar xvf ./files/${CONTAINERD_TARBALL} --strip-components=1 -C /usr/local/bin
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
sudo tar xvzf ./files/kubernetes/cni/${CNI_TARBALL} -C /opt/cni/bin
