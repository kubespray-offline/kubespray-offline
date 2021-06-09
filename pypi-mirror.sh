#!/bin/bash

KUBESPRAY_DIR=${KUBESPRAY_DIR:-./kubespray}

pypi-mirror download -d outputs/pypi/files -r ${KUBESPRAY_DIR}/requirements.txt
pypi-mirror create -d outputs/pypi/files -m outputs/pypi


