#!/bin/bash

# Create python3 env

echo "==> prepare-py.sh"

. /etc/os-release

. ./target-scripts/venv.sh

source ./scripts/set-locale.sh

echo "==> Update pip, etc"
pip install -U pip setuptools
#if [ "$(getenforce)" == "Enforcing" ]; then
#    pip install -U selinux
#fi

echo "==> Install python packages"
pip install -r requirements.txt
