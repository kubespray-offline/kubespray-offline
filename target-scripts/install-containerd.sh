#!/bin/bash

source ./config.sh

ENABLE_DOWNLOAD=${ENABLE_DOWNLOAD:-false}

if [ ! -e files ]; then
    mkdir -p files
fi

FILES_DIR=./files
if $ENABLE_DOWNLOAD; then
    FILES_DIR=./tmp/files
    mkdir -p $FILES_DIR
fi

# download files, if not found
download() {
    url=$1
    dir=$2

    filename=$(basename $1)
    mkdir -p ${FILES_DIR}/$dir

    if [ ! -e ${FILES_DIR}/$dir/$filename ]; then
        echo "==> download $url"
        (cd ${FILES_DIR}/$dir && curl -SLO $1)
    fi
}

if $ENABLE_DOWNLOAD; then
    download https://github.com/opencontainers/runc/releases/download/v${RUNC_VERSION}/runc.amd64 runc/v${RUNC_VERSION}
    download https://github.com/containerd/containerd/releases/download/v${CONTAINERD_VERSION}/containerd-${CONTAINERD_VERSION}-linux-amd64.tar.gz
    download https://github.com/containerd/nerdctl/releases/download/v${NERDCTL_VERSION}/nerdctl-${NERDCTL_VERSION}-linux-amd64.tar.gz
    download https://github.com/containernetworking/plugins/releases/download/v${CNI_VERSION}/cni-plugins-linux-amd64-v${CNI_VERSION}.tgz kubernetes/cni
else
    FILES_DIR=./files
fi

select_latest() {
    local latest=$(ls $* | tail -1)
    if [ -z "$latest" ]; then
        echo "No such file: $*"
        exit 1
    fi
    echo $latest
}

check_file() {
    if [ ! -e $1 ]; then
        echo "FATAL ERROR: No such file: $1"
        exit 1
    fi
}

# Install runc
echo "==> Install runc"
file="${FILES_DIR}/runc/v${RUNC_VERSION}/runc.amd64"
check_file $file
sudo cp "$file" /usr/local/bin/runc
sudo chmod 755 /usr/local/bin/runc

# Install nerdctl
echo "==> Install nerdctl"
file="${FILES_DIR}/nerdctl-${NERDCTL_VERSION}-linux-amd64.tar.gz"
check_file "$file"
tar xvf "$file" -C /tmp
sudo cp /tmp/nerdctl /usr/local/bin

# Install containerd
echo "==> Install containerd"
file="${FILES_DIR}/containerd-${CONTAINERD_VERSION}-linux-amd64.tar.gz"
check_file "$file"
sudo tar xvf "$file" --strip-components=1 -C /usr/local/bin
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
file="${FILES_DIR}/kubernetes/cni/cni-plugins-linux-amd64-v${CNI_VERSION}.tgz"
check_file "$file"
sudo tar xvzf "$file" -C /opt/cni/bin
