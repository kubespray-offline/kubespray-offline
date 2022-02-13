#!/bin/bash

if [ $# -ne 1 ]; then
    echo "usage: $0 <target>"
    exit 1
fi
target=$1

ROOT=$(cd ..; pwd)
WORKDIR=/root/kubespray-offline
VOLUMES="-v ${ROOT}:${WORKDIR} -v /var/run/docker.sock:/var/run/docker.sock"

CMD="cd ${WORKDIR} && ./create-repo.sh"

OPTS=
if [[ -t 1 ]]; then
    OPTS=$"OPTS -it"
fi
docker run ${OPTS} --rm ${VOLUMES} kubespray-offline-$target:latest /bin/bash -c "${CMD}"
