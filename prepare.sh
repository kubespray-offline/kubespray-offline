#!/bin/bash

if [ -e /etc/redhat-release ]; then
    sudo yum install -y yum-utils
    sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    sudo rpm -e podman-docker docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine
    sudo yum install -y python3 python3-pip rsync docker-ce docker-ce-cli
    sudo systemctl enable --now docker
else
    sources=/etc/apt/sources.list.d/download_docker_com_linux_ubuntu.list  # Same as kubespray
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee $sources
    sudo apt update
    sudo apt install -y python3 python3-pip python3-venv rsync docker-ce docker-ce-cli
fi

if [ ! -e ~/.venv/default ]; then
    python3 -m venv ~/.venv/default
fi

. ~/.venv/default/bin/activate
pip install -r requirements.txt
