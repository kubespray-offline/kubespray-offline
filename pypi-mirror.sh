#!/bin/bash

source config.sh

if [ ! -e $KUBESPRAY_DIR ]; then
    echo "No kubespray dir at $KUBESPRAY_DIR"
    exit 1
fi

source ~/.venv/default/bin/activate

export LANG=C  # It seems required for RHEL/CentOS?

echo "==> Create pypi mirror for kubespray"
set -x
pip install -U pip

OPTS="-d outputs/pypi/files"
pypi-mirror download $OPTS -r ${KUBESPRAY_DIR}/requirements.txt || exit 1
pypi-mirror download $OPTS --binary -r ${KUBESPRAY_DIR}/requirements.txt || exit 1
pypi-mirror download $OPTS pip setuptools wheel || exit 1
pypi-mirror download $OPTS pip setuptools==40.9.0 || exit 1  # For RHEL...

pypi-mirror create -d outputs/pypi/files -m outputs/pypi || exit 1
