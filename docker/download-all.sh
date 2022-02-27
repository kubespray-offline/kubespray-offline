#!/bin/bash

if [ $# -ne 1 ]; then
    echo "usage: $0 <target>"
    exit 1
fi
target=$1

ROOT=$(cd ..; pwd)
WORKDIR=/root/kubespray-offline
VOLUMES="-v ${ROOT}:${WORKDIR} -v /var/run/docker.sock:/var/run/docker.sock"

CMD="cd ${WORKDIR}; ./install-docker.sh; ./download-all.sh"

docker run -it --rm ${VOLUMES} kubespray-offline-$target:latest /bin/bash -c "${CMD}"
