#!/bin/bash

cd $(dirname $0)
source ./common.sh

run_in_docker "./prepare-py.sh && ./pypi-mirror.sh && SKIP_DOWNLOAD_IMAGES=true ./download-kubespray-files.sh"
