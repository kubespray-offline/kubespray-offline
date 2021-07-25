#!/bin/bash

# Install required packages
if [ -e /etc/redhat-release ]; then
    sudo yum check-update
    if [ ! -e /etc/yum.repos.d/docker-ce.repo ]; then
        sudo yum install -y yum-utils
        sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    fi
    sudo rpm -e podman-docker docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine
    sudo yum install -y python3 python3-pip rsync docker-ce docker-ce-cli
    sudo yum install -y libffi-devel # pypi-mirror
    sudo systemctl enable --now docker
else
    sources=/etc/apt/sources.list.d/download_docker_com_linux_ubuntu.list  # Same as kubespray
    if [ ! -e $sources ]; then
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee $sources
    fi
    sudo apt update
    sudo dpkg -r docker docker-engine docker.io containerd runc
    sudo apt install -y python3 python3-pip python3-venv rsync docker-ce docker-ce-cli
    sudo apt install -y libffi-dev # pypi-mirror
fi

# Set up docker proxy
if [ -n "$http_proxy" ] && [ ! -e /etc/systemd/system/docker.service.d/http-proxy.conf ]; then
    [ ! -d /etc/systemd/system/docker.service.d ] && sudo mkdir /etc/systemd/system/docker.service.d
    cat <<EOF | sudo tee /etc/systemd/system/docker.service.d/http-proxy.conf
[Service]
Environment="HTTP_PROXY=$http_proxy" "HTTPS_PROXY=$https_proxy"
EOF
    sudo systemctl daemon-reload
    sudo systemctl restart docker
fi

# Create python3 venv
if [ ! -e ~/.venv/default ]; then
    python3 -m venv ~/.venv/default
fi

. ~/.venv/default/bin/activate
pip install -r requirements.txt
