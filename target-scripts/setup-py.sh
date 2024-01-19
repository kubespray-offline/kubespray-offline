#!/bin/bash

. /etc/os-release

# Install python and dependencies
echo "===> Install python, venv, etc"
if [ -e /etc/redhat-release ]; then
    sudo yum install -y --disablerepo=* --enablerepo=offline-repo gcc libffi-devel openssl-devel || exit 1

    if [[ "$VERSION_ID" =~ ^7.* ]]; then
        echo "FATAL: RHEL/CentOS 7 is not supported anymore."
        exit 1
    elif [[ "$VERSION_ID" =~ ^8.* ]]; then
          sudo yum install -y --disablerepo=* --enablerepo=offline-repo python39 python39-devel || exit 1
    elif [[ "$VERSION_ID" =~ ^9.* ]]; then
          sudo yum install -y --disablerepo=* --enablerepo=offline-repo python39 python39-devel || exit 1
    else
        sudo dnf install -y --disablerepo=* --enablerepo=offline-repo python python-devel || exit 1
    fi
else
    sudo apt update
    case "$VERSION_ID" in
        20.04)
            sudo apt install -y python3.9-venv || exit 1
            ;;
        *)
            sudo apt install -y python3-venv || exit 1
            ;;
    esac
fi
