#!/bin/bash

# My IP address
for ip in $(hostname -I); do
    if [[ $ip =~ ^192\. ]]; then
        MYIP=$ip
    fi
done
MYIP=${MYIP:-10.0.2.15}
echo "MYIP = $MYIP"

source /etc/os-release

BASEDIR=$(cd $(dirname $0)/..; pwd)
source $BASEDIR/config.sh
source $BASEDIR/outputs/config.sh

VENV_DIR=${VENV_DIR:-~/.venv/default}

cd $BASEDIR/outputs

venv() {
    if [ ! -d ${VENV_DIR} ]; then
        python3 -m venv ${VENV_DIR} || exit 1
    fi
    source ${VENV_DIR}/bin/activate
}

prepare_kubespray() {
    # extract kubespray
    cd $BASEDIR/outputs
    if [ ! -d kubespray-test ]; then
        tar xvzf ./files/${KUBESPRAY_TARBALL}
        mv kubespray-${KUBESPRAY_VERSION} kubespray-test
    fi
    cd kubespray-test

    # install ansible
    #pip install -U setuptools # adhoc: update to intermediate version
    #pip install -U pip wheel
    #pip install -U setuptools # update to latest version
    #pip install -r requirements.txt --no-build-isolation || exit 1
    pip install -r requirements.txt || exit 1
}

do_kubespray() {
    venv
    
    cd $BASEDIR/outputs/kubespray-test

    # copy offline repo playboo
    cp -r $BASEDIR/outputs/playbook/* ./

    set -x
    pwd
    if [ ! -d inventory/mycluster ]; then
        cp -rfp inventory/sample inventory/mycluster
    fi

    echo "===> Generate offline config"
    cat <<EOF >inventory/mycluster/group_vars/all/offline.yml
http_server: "http://$MYIP:$NGINX_PORT"
registry_host: "$MYIP:$REGISTRY_PORT"

containerd_insecure_registries:
  - "{{ registry_host }}"

files_repo: "{{ http_server }}/files"
yum_repo: "{{ http_server }}/rpms"
ubuntu_repo: "{{ http_server }}/debs"

# Registry overrides
kube_image_repo: "{{ registry_host }}"
gcr_image_repo: "{{ registry_host }}"
docker_image_repo: "{{ registry_host }}"
quay_image_repo: "{{ registry_host }}"

# Download URLs: See roles/download/defaults/main.yml of kubespray.
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

runc_download_url: "{{ files_repo }}/runc.{{ image_arch }}"
nerdctl_download_url: "{{ files_repo }}/nerdctl-{{ nerdctl_version }}-{{ ansible_system | lower }}-{{ image_arch }}.tar.gz"
containerd_download_url: "{{ files_repo }}/containerd-{{ containerd_version }}-linux-{{ image_arch }}.tar.gz"
EOF
    
    echo "===> Generate inventory"
    CONFIG_FILE=inventory/mycluster/hosts.yaml python3 contrib/inventory_builder/inventory.py $MYIP || exit 1
    cat inventory/mycluster/hosts.yaml
    
    echo "===> Execute offline repo playbook"
    ansible-playbook -i inventory/mycluster/hosts.yaml  --become --become-user=root offline-repo.yml || exit 1

    echo "===> Execute kubespray"
    # Hack #8339
    PULL_CMD="/usr/local/bin/nerdctl -n k8s.io pull --quiet --insecure-registry"
    ansible-playbook -i inventory/mycluster/hosts.yaml  --become --become-user=root \
        -e "image_pull_command='$PULL_CMD'" -e "image_pull_command_on_localhost='$PULL_CMD'" \
        cluster.yml \
        || exit 1
}

venv
prepare_kubespray
do_kubespray

mkdir ~/.kube
sudo cat /etc/kubernetes/admin.conf > ~/.kube/config
chmod 600 ~/.kube/config
