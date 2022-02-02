#!/bin/bash

echo "==> prepare-pkgs.sh"

. /etc/os-release

# Install required packages
if [ -e /etc/redhat-release ]; then
    echo "==> Install required packages"
    sudo yum check-update
    sudo yum install -y python3 python3-pip rsync \
         gcc python3-devel libffi-devel \
         createrepo

    if [ "$VERSION_ID" != "7" ]; then
        # RHEL/CentOS 8
        if ! command -v repo2module >/dev/null; then
            echo "==> Install modulemd-tools"
            sudo dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
            sudo dnf copr enable -y frostyx/modulemd-tools-epel
            sudo dnf install -y modulemd-tools
        fi
    fi
else
    sudo apt update
    sudo apt -y install lsb-release curl gpg python3 || exit 1
    sudo apt install -y python3 python3-pip python3-venv rsync || exit 1
    sudo apt install -y gcc python3-dev libffi-dev || exit 1 # pypi-mirror
fi
