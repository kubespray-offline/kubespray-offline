#!/bin/bash

KUBESPRAY_DIR=${KUBESPRAY_DIR:-./kubespray}

pypi-mirror download -d offline/pypi/files -r ${KUBESPRAY_DIR}/requirements.txt
pypi-mirror create -d offline/pypi/files -m offline/pypi


