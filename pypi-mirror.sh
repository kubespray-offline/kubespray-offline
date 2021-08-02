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

DEST="-d outputs/pypi/files"
echo "===> Download requirements"
pypi-mirror download $DEST -r ${KUBESPRAY_DIR}/requirements.txt || exit 1

REQ=requirements.tmp
sed "s/^ansible/#ansible/" ${KUBESPRAY_DIR}/requirements.txt > $REQ  # Ansible does not provide binary packages
echo "PyYAML" >> $REQ  # Ansible dependency
for pyver in 3.6 3.7 3.8 3.9; do
    echo "===> Download binary for python $pyver"
    pypi-mirror download $DEST --binary --python-version $pyver -r $REQ || exit 1
done
/bin/rm $REQ

echo "===> Download pip, setuptools, wheel"
pypi-mirror download $DEST pip setuptools wheel || exit 1
pypi-mirror download $DEST pip setuptools==40.9.0 || exit 1  # For RHEL...

pypi-mirror create $DEST -m outputs/pypi || exit 1

echo "pypi-mirror.sh done"
