#!/bin/bash

source /etc/os-release
source ./config.sh

if [ "$docker" != "podman" ]; then
    if ! command -v $docker >/dev/null 2>&1; then
        echo "No $docker installed"
        exit 1
    fi
fi

if [ -e /etc/redhat-release ] && [[ "$VERSION_ID" =~ ^7.* ]]; then
    if [ "$(getenforce)" == "Enforcing" ]; then
        echo "You must disable SELinux for RHEL7/CentOS7"
        exit 1
    fi
fi
