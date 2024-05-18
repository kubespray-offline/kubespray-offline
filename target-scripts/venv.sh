#!/bin/bash

source /etc/os-release

# Now always use specific python version
PY_VERSION=3.11

if [ -e /etc/redhat-release ]; then
    if [[ "$VERSION_ID" =~ ^7.* ]]; then
        echo "FATAL: RHEL/CentOS 7 is not supported anymore"
        exit 1
        #if [ "$(getenforce)" == "Enforcing" ]; then
        #    echo "You must disable SELinux for RHEL7/CentOS7"
        #    exit 1
        #fi
        #python3=$(scl enable rh-python38 "which python3")
    fi
else
    if [[ "$VERSION_ID" =~ ^24 ]]; then
        PY_VERSION=3.12
    fi
fi

python3=python${PY_VERSION}
VENV_DIR=${VENV_DIR:-~/.venv/${PY_VERSION}}

echo "python3 = $python3"
echo "VENV_DIR = ${VENV_DIR}"
if [ ! -e ${VENV_DIR} ]; then
    $python3 -m venv ${VENV_DIR}
fi
source ${VENV_DIR}/bin/activate
