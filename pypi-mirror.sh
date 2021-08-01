#!/bin/bash

source config.sh

if [ ! -e $KUBESPRAY_DIR ]; then
    echo "No kubespray dir at $KUBESPRAY_DIR"
    exit 1
fi

source ~/.venv/default/bin/activate

export LANG=C  # It seems required for RHEL/CentOS?

echo "==> Create pypi mirror for kubespray"
pip install -U pip
pypi-mirror download -d outputs/pypi/files -r ${KUBESPRAY_DIR}/requirements.txt
pypi-mirror download -d outputs/pypi/files pip setuptools wheel
pypi-mirror download -d outputs/pypi/files pip setuptools==40.9.0 # For RHEL...
pypi-mirror create -d outputs/pypi/files -m outputs/pypi


