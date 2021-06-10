#!/bin/bash

CURRENT_DIR=$(cd $(dirname $0); pwd)

if [ -z "$MYIP" ]; then
    MYIP=$(ip -o route get to 8.8.8.8 | sed -n 's/.*src \([0-9.]\+\).*/\1/p')
fi
KUBESPRAY_DIR=${KUBESPRAY_DIR:-./kubespray}
INVENTORY_DIR=${INVENTORY_DIR:-inventory/mycluster}

if [ ! -e $KUBESPRAY_DIR ]; then
    echo "No kubespray dir at $KUBESPRAY_DIR"
    exit 1
fi
if [ ! -e $KUBESPRAY_DIR/$INVENTORY_DIR ]; then
    echo "No inventory dir at $KUBESPRAY_DIR/$INVENTORY_DIR"
    exit 1
fi

[ ! -e /etc/kubernetes ] && sudo mkdir /etc/kubernetes

echo "MYIP = $MYIP"

cat >${KUBESPRAY_DIR}/${INVENTORY_DIR}/local_download.yml <<EOF
all:
  hosts:
    localhost:
      ansible_host: ${MYIP}
      ip: ${MYIP}
      access_ip: ${MYIP}
  children:
    kube_control_plane:
      hosts:
        localhost:
    kube_node:
      hosts:
        localhost:
    etcd:
      hosts:
        localhost:
    k8s_cluster:
      children:
        kube_control_plane:
        kube_node:
    calico_rr:
      hosts: {}
EOF

cd ${KUBESPRAY_DIR}

ADDONS="
-e helm_enabled=True
-e registry_enabled=True
-e metrics_server_enabled=True
-e local_path_provisioner_enabled=True
-e local_volume_provisioner_enabled=True
-e ingress_nginx_enabled=True
-e metallb_enabled=True
"
#-e rbd_provisioner_enabled=True

TAGS="-t download"
if [ "$1" = "install" ]; then
    TAGS=""
fi

PROXY=""
if [ -n "$http_proxy" ]; then
    PROXY="-e http_proxy=$http_proxy"
fi
if [ -n "$https_proxy" ]; then
    PROXY="$PROXY -e https_proxy=$https_proxy"
fi

ansible-playbook \
    -i ${INVENTORY_DIR}/local_download.yml \
    ${TAGS} \
    ${PROXY} \
    -e download_run_once=True \
    -e download_localhost=True \
    -e download_cache_dir=${CURRENT_DIR}/outputs/kubespray \
    ${ADDONS} \
    --become --become-user=root \
    -vv \
    cluster.yml

sudo chown -R "$USER" ${CURRENT_DIR}/outputs/kubespray
