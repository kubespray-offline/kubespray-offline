#!/bin/bash

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
