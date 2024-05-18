ROOT=$(cd ..; pwd)
WORKDIR=/root/kubespray-offline
VOLUMES="-v ${ROOT}:${WORKDIR} -v /var/run/docker.sock:/var/run/docker.sock -v /run/containerd/containerd.sock:/run/containerd/containerd.sock"

if [ $# -ne 1 ]; then
    echo "usage: $0 <target>"
    exit 1
fi
target=$1

OPTS=
if [[ -t 1 ]]; then
    OPTS="$OPTS -it"
fi

run_in_docker() {
    docker run ${OPTS} --rm ${VOLUMES} tmurakam/kubespray-offline-$target:latest /bin/bash -c "cd ${WORKDIR} && $@"
}
