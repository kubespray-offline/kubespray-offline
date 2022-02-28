#!/bin/bash

source ./common.sh

if [ $# -ne 1 ]; then
    echo "usage: $0 <target>"
    exit 1
fi
target=$1

CMD="cd ${WORKDIR} && ./create-repo.sh"

OPTS=
if [[ -t 1 ]]; then
    OPTS="$OPTS -it"
fi
docker run ${OPTS} --rm ${VOLUMES} tmurakam/kubespray-offline-$target:latest /bin/bash -c "${CMD}"
