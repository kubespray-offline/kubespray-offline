#!/bin/bash

source ./common.sh

CMD="cd ${WORKDIR} && ./download-kubespray-files.sh"

#docker run -it --rm -v ${ROOT}:${WORKDIR} kubespray-offline-cent8:latest /bin/bash -c "${CMD}"
docker run -it --rm ${VOLUMES} tmurakam/kubespray-offline-ubuntu2004:latest /bin/bash -c "${CMD}"
