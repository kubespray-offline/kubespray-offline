#!/bin/bash

source config.sh

if [ ! -e $KUBESPRAY_DIR ]; then
    echo "No kubespray dir at $KUBESPRAY_DIR"
    exit 1
fi

VENV_DIR=${VENV_DIR:-~/.venv/default}
if [ ! -e ${VENV_DIR} ]; then
    python3 -m venv ${VENV_DIR}
fi
source ${VENV_DIR}/bin/activate

echo "==> Create pypi mirror for kubespray"
#set -x
pip install -U pip python-pypi-mirror

DEST="-d outputs/pypi/files"
PLATFORM="--platform manylinux2014_x86_64"  # PEP-599
#PLATFORM="--platform manylinux_2_17_x86_64"  # PEP-600

REQ=requirements.tmp
sed "s/^ansible/#ansible/" ${KUBESPRAY_DIR}/requirements.txt > $REQ  # Ansible does not provide binary packages
echo "PyYAML" >> $REQ  # Ansible dependency
for pyver in 3.6 3.7 3.8 3.9; do
    echo "===> Download binary for python $pyver"
    pip download $DEST --only-binary :all: --python-version $pyver $PLATFORM -r $REQ || exit 1
done
/bin/rm $REQ

echo "===> Download source packages"
pip download $DEST --no-binary :all: -r ${KUBESPRAY_DIR}/requirements.txt
if [ $? -ne 0 ]; then
    # LANG=C is required for RHEL 8(?)
    echo "Failed, retry with LANG=C..."
    LANG=C pip download $DEST --no-binary :all: -r ${KUBESPRAY_DIR}/requirements.txt
fi

echo "===> Download pip, setuptools, wheel"
pip download $DEST pip setuptools wheel || exit 1
pip download $DEST pip setuptools==40.9.0 || exit 1  # For RHEL...

pypi-mirror create $DEST -m outputs/pypi || exit 1

echo "pypi-mirror.sh done"
