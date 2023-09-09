#!/bin/bash

cd $(dirname $0)
source ./common.sh

if [ $# -ne 1 ]; then
    echo "usage: $0 <target>"
    exit 1
fi
target=$1

CMD="cd ${WORKDIR}; ./install-docker.sh; ./download-all.sh"

OPTS=
if [ -t 0 ]; then
    # tty mode
    OPTS="-it"
fi
docker run ${OPTS} --rm ${VOLUMES} tmurakam/kubespray-offline-$target:latest /bin/bash -c "${CMD}"
