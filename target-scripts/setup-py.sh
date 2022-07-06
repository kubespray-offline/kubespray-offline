#!/bin/bash

# Install python and dependencies
echo "===> Install python, venv, etc"
if [ -e /etc/redhat-release ]; then
    sudo yum install -y --disablerepo=* --enablerepo=offline-repo gcc libffi-devel openssl-devel

    . /etc/os-release
    if [[ "$VERSION_ID" =~ ^7.* ]]; then
        sudo yum install -y --disablerepo=* --enablerepo=offline-repo rh-python38 rh-python38-python-devel
    else
        sudo yum install -y --disablerepo=* --enablerepo=offline-repo python38 python38-devel
        sudo alternatives --set python3 /usr/bin/python3.8 || exit 1
    fi
else
    sudo apt update
    #sudo apt install -y python3-venv gcc python3-dev libffi-dev libssl-dev
    sudo apt install -y python3-venv
fi
