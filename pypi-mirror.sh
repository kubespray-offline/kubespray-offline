#!/bin/bash

source config.sh

if [ ! -e $KUBESPRAY_DIR ]; then
    echo "No kubespray dir at $KUBESPRAY_DIR"
    exit 1
fi

source ~/.venv/default/bin/activate

export LANG=C  # It seems required for RHEL/CentOS?

echo "==> Create pypi mirror for kubespray"
#set -x
pip install -U pip

OPTS="-d outputs/pypi/files"
echo "===> Download requirements"
pypi-mirror download $OPTS -r ${KUBESPRAY_DIR}/requirements.txt || exit 1

sed "s/^ansible/#ansible/" ${KUBESPRAY_DIR}/requirements.txt > requirements2.txt
for pyver in 3.6 3.7 3.8 3.9; do
    echo "===> Download binary for python $pyver"
    pypi-mirror download $OPTS --binary --python-version $pyver -r requirements2.txt || exit 1
    pypi-mirror download $OPTS --binary --python-version $pyver PyYAML || exit 1
done

echo "===> Download pip, setuptools, wheel"
pypi-mirror download $OPTS pip setuptools wheel || exit 1
pypi-mirror download $OPTS pip setuptools==40.9.0 || exit 1  # For RHEL...

pypi-mirror create -d outputs/pypi/files -m outputs/pypi || exit 1

echo "pypi-mirror.sh done"
