ROOT=$(cd ..; pwd)
WORKDIR=/root/kubespray-offline
VOLUMES="-v ${ROOT}:${WORKDIR} -v /var/run/docker.sock:/var/run/docker.sock"
