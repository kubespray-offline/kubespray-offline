#!/bin/bash

# Create python3 env

echo "==> prepare-py.sh"

. /etc/os-release

python3=python3
if [ -e /etc/redhat-release ] && [[ "$VERSION_ID" =~ ^7.* ]]; then
    if [ "$(getenforce)" == "Enforcing" ]; then
        echo "You must disable SELinux for RHEL7/CentOS7"
        exit 1
    fi
    python3=$(scl enable rh-python38 "which python3")
fi
echo "python3 = $python3"

VENV_DIR=${VENV_DIR:-~/.venv/default}
echo "VENV_DIR = ${VENV_DIR}"
if [ ! -e ${VENV_DIR} ]; then
    $python3 -m venv ${VENV_DIR}
fi
source ${VENV_DIR}/bin/activate

source ./scripts/set-locale.sh

echo "==> Update pip, etc"
pip install -U pip setuptools
if [ "$(getenforce)" == "Enforcing" ]; then
    pip install -U selinux
fi

echo "==> Install python packages"
pip install -r requirements.txt
