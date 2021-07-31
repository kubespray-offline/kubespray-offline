#!/bin/bash

# My IP address
MYIP=10.0.2.15

source /etc/os-release

BASEDIR=$(cd $(dirname $0)/..; pwd)
source $BASEDIR/config.sh
source $BASEDIR/outputs/config.sh

cd $BASEDIR/outputs

venv() {
    if [ ! -d ~/.venv/default ]; then
        python3 -m venv ~/.venv/default || exit 1
    fi
    source ~/.venv/default/bin/activate
}

prepare_kubespray() {
    # extract kubespray
    cd $BASEDIR/outputs
    if [ ! -d kubespray-test ]; then
        tar xvzf ./files/${KUBESPRAY_TARBALL}
        mv kubespray-${KUBESPRAY_VERSION} kubespray-test
    fi
    cd kubespray-test

    if [ -e /etc/redhat-release ]; then
        sudo yum install -y gcc python3-devel libffi-devel openssl-devel || exit 1
    else
        sudo apt update
        sudo apt install -y python3-venv gcc python3-dev libffi-dev libssl-dev
    fi

    venv

    # install ansible
    pip install -U setuptools # adhoc: update to intermediate version
    pip install -U pip wheel
    pip install -U setuptools # update to latest version
    pip install -r requirements.txt --no-build-isolation || exit 1
}

do_kubespray() {
    venv
    
    cd $BASEDIR/outputs/kubespray-test

    set -x
    pwd
    if [ ! -d inventory/mycluster ]; then
        cp -rfp inventory/sample inventory/mycluster
    fi

    echo "===> Generate offline config"
    REGISTRY=localhost:$REGISTRY_PORT
    cat <<EOF >inventory/mycluster/group_vars/all/offline.yml
# Registry overrides
kube_image_repo: "$REGISTRY"
gcr_image_repo: "$REGISTRY"
docker_image_repo: "$REGISTRY"
quay_image_repo: "$REGISTRY"

files_repo: "http://localhost:$NGINX_PORT/files"
yum_repo: "http://localhost:$NGINX_PORT/rpms"
ubuntu_repo: "http://localhost:$NGINX_PORT/debs"

kubeadm_download_url: "{{ files_repo }}/kubernetes/{{ kube_version }}/kubeadm"
kubectl_download_url: "{{ files_repo }}/kubernetes/{{ kube_version }}/kubectl"
kubelet_download_url: "{{ files_repo }}/kubernetes/{{ kube_version }}/kubelet"
# etcd is optional if you **DON'T** use etcd_deployment=host
etcd_download_url: "{{ files_repo }}/kubernetes/etcd/etcd-{{ etcd_version }}-linux-amd64.tar.gz"
cni_download_url: "{{ files_repo }}/kubernetes/cni/cni-plugins-linux-{{ image_arch }}-{{ cni_version }}.tgz"
crictl_download_url: "{{ files_repo }}/kubernetes/cri-tools/crictl-{{ crictl_version }}-{{ ansible_system | lower }}-{{ image_arch }}.tar.gz"
# If using Calico
calicoctl_download_url: "{{ files_repo }}/kubernetes/calico/{{ calico_ctl_version }}/calicoctl-linux-{{ image_arch }}"
# If using Calico with kdd
calico_crds_download_url: "{{ files_repo }}/kubernetes/calico/{{ calico_version }}.tar.gz"

# CentOS/Redhat/AlmaLinux
## Docker / Containerd
docker_rh_repo_base_url: "{{ yum_repo }}/docker-ce/\$releasever/\$basearch/stable"
docker_rh_repo_gpgkey: "{{ yum_repo }}/docker-ce/gpg"

# Ubuntu
## Docker
docker_ubuntu_repo_base_url: "{{ ubuntu_repo }}/docker-ce"
docker_ubuntu_repo_gpgkey: "{{ ubuntu_repo }}/docker-ce/gpg"
## Containerd
containerd_ubuntu_repo_base_url: "{{ ubuntu_repo }}/containerd"
containerd_ubuntu_repo_gpgkey: "{{ ubuntu_repo }}/containerd/gpg"
#containerd_ubuntu_repo_repokey: 'YOURREPOKEY'

# Force use latest docker (do not downgrade)
docker_version: latest
containerd_version: latest
EOF
    
    echo "===> Generate inventory"
    CONFIG_FILE=inventory/mycluster/hosts.yaml python3 contrib/inventory_builder/inventory.py $MYIP || exit 1
    cat inventory/mycluster/hosts.yaml
    
    echo "===> Execute kubespray"
    ansible-playbook -i inventory/mycluster/hosts.yaml  --become --become-user=root cluster.yml
}

prepare_kubespray
do_kubespray
