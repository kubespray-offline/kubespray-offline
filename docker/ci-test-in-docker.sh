#!/bin/bash

cd $(dirname $0)
source ./common.sh

if [ $# -ne 1 ]; then
    echo "usage: $0 <target>"
    exit 1
fi
target=$1

IS_OFFLINE=${IS_OFFLINE:-true}
CMD="cd ${WORKDIR} && IS_OFFLINE=${IS_OFFLINE} ./ci-test/ci-test.sh"

OPTS=
if [[ -t 1 ]]; then
    OPTS="$OPTS -it"
fi
docker run ${OPTS} --rm ${VOLUMES} tmurakam/kubespray-offline-$target:latest /bin/bash -c "${CMD}"
