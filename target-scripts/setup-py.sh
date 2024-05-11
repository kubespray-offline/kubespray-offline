#!/bin/bash

. /etc/os-release

# Install python and dependencies
echo "===> Install python, venv, etc"
if [ -e /etc/redhat-release ]; then
    sudo yum install -y --disablerepo=* --enablerepo=offline-repo gcc libffi-devel openssl-devel || exit 1

    if [[ "$VERSION_ID" =~ ^7.* ]]; then
        echo "FATAL: RHEL/CentOS 7 is not supported anymore."
        exit 1
    #elif [[ "$VERSION_ID" =~ ^8.* ]]; then
    #elif [[ "$VERSION_ID" =~ ^9.* ]]; then
    #else
    fi
    sudo yum install -y --disablerepo=* --enablerepo=offline-repo python3.11 python3.11-devel || exit 1
else
    sudo apt update
    #case "$VERSION_ID" in
    #    20.04)
    #        sudo apt install -y python3.11-venv || exit 1
    #        ;;
    #    *)
    #        sudo apt install -y python3-venv || exit 1
    #        ;;
    #esac
    sudo apt install -y python3.11-venv python3.11-dev gcc libffi-dev libssl-dev || exit 1
fi
