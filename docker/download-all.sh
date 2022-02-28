#!/bin/bash

source ./common.sh

if [ $# -ne 1 ]; then
    echo "usage: $0 <target>"
    exit 1
fi
target=$1

CMD="cd ${WORKDIR}; ./install-docker.sh; ./download-all.sh"

docker run -it --rm ${VOLUMES} tmurakam/kubespray-offline-$target:latest /bin/bash -c "${CMD}"
