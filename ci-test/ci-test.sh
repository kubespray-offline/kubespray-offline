#!/bin/bash

run() {
    echo "=> Test: Running: $*"
    $* || {
        echo "Failed in : $*"
        exit 1
    }
}

BASE_DIR=$(cd $(dirname $0)/..; pwd)
OUTPUTS_DIR="${BASE_DIR}/outputs"

echo "outputs dir = ${OUTPUTS_DIR}"
cd ${OUTPUTS_DIR}

# Test: Try to install containerd
#run ./install-containerd.sh

# Test: Extract kubespray
run ./extract-kubespray.sh

# Test: setup python
export IS_OFFLINE=false
run ./setup-py.sh

# Setup PyPI mirror
echo "===> Setup PyPI mirror"
mkdir -p ~/.config/pip/
cat <<EOF >~/.config/pip/pip.conf
[global]
index = file://${OUTPUTS_DIR}/pypi/
index-url = file://${OUTPUTS_DIR}/pypi/
trusted-host = localhost
EOF

# Test: create venv
source ./venv.sh

# Test: install ansible
source ./config.sh
pip install -r kubespray-${KUBESPRAY_VERSION}/requirements.txt
