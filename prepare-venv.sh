#!/bin/bash

# Create python3 venv

echo "==> prepare-venv.sh"

VENV_DIR=${VENV_DIR:-~/.venv/default}
echo "VENV_DIR = ${VENV_DIR}"
if [ ! -e ${VENV_DIR} ]; then
    python3 -m venv ${VENV_DIR}
fi
source ${VENV_DIR}/bin/activate

echo "==> Install python packages"
pip install -r requirements.txt
