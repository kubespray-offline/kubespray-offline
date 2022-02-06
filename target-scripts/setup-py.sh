#!/bin/bash

# Install python and dependencies
if [ -e /etc/redhat-release ]; then
    sudo yum install -y --disablerepo=* --enablerepo=offline-repo python3 gcc python3-devel libffi-devel openssl-devel || exit 1
else
    sudo apt update
    #sudo apt install -y python3-venv gcc python3-dev libffi-dev libssl-dev
    sudo apt install -y python3-venv
fi
