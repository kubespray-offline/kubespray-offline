#!/bin/bash

source /etc/os-release

# Select python version
source "$(dirname "${BASH_SOURCE[0]}")/pyver.sh"

python3=python${PY}
VENV_DIR=${VENV_DIR:-~/.venv/${PY}}

echo "python3 = $python3"
echo "VENV_DIR = ${VENV_DIR}"
if [ ! -e ${VENV_DIR} ]; then
    $python3 -m venv ${VENV_DIR}
fi
source ${VENV_DIR}/bin/activate
