#!/bin/bash

source config.sh

if [ ! -e $KUBESPRAY_DIR ]; then
    echo "No kubespray dir at $KUBESPRAY_DIR"
    exit 1
fi

source ./.venv/bin/activate

echo "==> Create pypi mirror for kubespray"
pypi-mirror download -d outputs/pypi/files -r ${KUBESPRAY_DIR}/requirements.txt
pypi-mirror download -d outputs/pypi/files pip setuptools wheel
pypi-mirror create -d outputs/pypi/files -m outputs/pypi


