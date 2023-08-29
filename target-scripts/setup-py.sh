#!/bin/bash

# Install python and dependencies
echo "===> Install python, venv, etc"
if [ -e /etc/redhat-release ]; then
    sudo yum install -y --disablerepo=* --enablerepo=offline-repo gcc libffi-devel openssl-devel

    . /etc/os-release
    if [[ "$VERSION_ID" =~ ^7.* ]]; then
        echo "FATAL: RHEL/CentOS 7 is not supported anymore."
    elif [[ "$VERSION_ID" =~ ^8.* ]]; then
          sudo yum install -y --disablerepo=* --enablerepo=offline-repo python39 python39-devel
    elif [[ "$VERSION_ID" =~ ^9.* ]]; then
          sudo yum install -y --disablerepo=* --enablerepo=offline-repo python39 python39-devel
    else
        sudo dnf install -y --disablerepo=* --enablerepo=offline-repo python python-devel
    fi
else
    sudo apt update
    #sudo apt install -y python3-venv gcc python3-dev libffi-dev libssl-dev
    sudo apt install -y python3-venv
fi
