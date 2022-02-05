#!/bin/bash

ROOT=$(cd ..; pwd)
WORKDIR=/root/kubespray-offline
VOLUMES="-v ${ROOT}:${WORKDIR} -v /var/run/docker.sock:/var/run/docker.sock"

CMD="cd ${WORKDIR} && ./create-repo.sh"

docker run -it --rm ${VOLUMES} kubespray-offline-alma8:latest /bin/bash -c "${CMD}"

docker run -it --rm ${VOLUMES} kubespray-offline-ubuntu2004:latest /bin/bash -c "${CMD}"
