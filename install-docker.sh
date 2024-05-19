#!/bin/bash

echo "==> install-docker.sh"

. /etc/os-release
. ./scripts/common.sh

# Install Docker CE
if [ -e /etc/redhat-release ]; then
    # RHEL
    $sudo dnf check-update
    if [ ! -e /etc/yum.repos.d/docker-ce.repo ]; then
        echo "==> Install docker-ce repo"
        $sudo dnf install -y dnf-utils
        $sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    fi

    if ! command -v docker >/dev/null; then
        $sudo rpm -e podman-docker docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine
        $sudo rpm -e buildah  # RHEL9

        echo "==> Install docker-ce related packages"
        $sudo dnf install -y docker-ce docker-ce-cli
    fi
    $sudo systemctl enable --now docker
else
    # Ubuntu
    sources=/etc/apt/sources.list.d/download_docker_com_linux_ubuntu.list  # Same as kubespray
    if [ ! -e $sources ]; then
        echo "==> Install docker-ce repo"
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | $sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg || exit 1
        echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | $sudo tee $sources
    fi

    if ! command -v docker >/dev/null; then
        $sudo apt update
        $sudo dpkg -r docker docker-engine docker.io containerd runc
    
        echo "==> Install docker-ce related packages"
        $sudo apt install -y docker-ce docker-ce-cli || exit 1
    fi
fi

# Set up docker proxy
if [ -n "$http_proxy" ] && [ ! -e /etc/systemd/system/docker.service.d/http-proxy.conf ]; then
    [ ! -d /etc/systemd/system/docker.service.d ] && $sudo mkdir /etc/systemd/system/docker.service.d
    cat <<EOF | $sudo tee /etc/systemd/system/docker.service.d/http-proxy.conf
[Service]
Environment="HTTP_PROXY=$http_proxy" "HTTPS_PROXY=$https_proxy"
EOF
    $sudo systemctl daemon-reload
    $sudo systemctl restart docker
fi

# Install nerdctl
./install-nerdctl.sh
