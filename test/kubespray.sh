#!/bin/bash

# My IP address
for ip in $(hostname -I); do
    if [[ $ip =~ ^192\. ]]; then
        INSTALLER_IP=$ip
    fi
done
INSTALLER_IP=${INSTALLER_IP:-10.0.2.15}
echo "INSTALLER_IP = $INSTALLER_IP"

IPS=${IPS:-${INSTALLER_IP}}

source /etc/os-release

python3=python3
if [ -e /etc/redhat-release ]; then
    if [[ "$VERSION_ID" =~ ^7.* ]]; then
        PATH=/opt/rh/rh-python38/root/usr/bin:$PATH
        export PATH
    else
        python3=python3.8
    fi
fi

BASEDIR=$(cd $(dirname $0)/..; pwd)
source $BASEDIR/config.sh
source $BASEDIR/outputs/config.sh
ansible_in_container=${ansible_in_container:-false}

KUBESPRAY_TARBALL=kubespray-${KUBESPRAY_VERSION}.tar.gz
VENV_DIR=${VENV_DIR:-~/.venv/default}

cd $BASEDIR/test

prepare_pkgs() {
    if [ "${NAME}" = "Ubuntu" ] && [ "${VERSION_ID}" = "22.04" ]; then
        sudo apt install -y gcc python3-dev libffi-dev # libssl-dev
    fi
}

venv() {
    if [ ! -d ${VENV_DIR} ]; then
        $python3 -m venv ${VENV_DIR} || exit 1
    fi
    source ${VENV_DIR}/bin/activate
}

prepare_kubespray() {
    # extract kubespray
    cd $BASEDIR/outputs
    ./extract-kubespray.sh || exit 1

    [ -e $BASEDIR/test/kubespray-test ] && /bin/rm -rf $BASEDIR/test/kubespray-test
    mv kubespray-${KUBESPRAY_VERSION} $BASEDIR/test/kubespray-test

    cd $BASEDIR/test/kubespray-test
    
    # install ansible
    if [ "$ansible_in_container" != "true" ]; then
        #pip install -U setuptools # adhoc: update to intermediate version
        pip install -U pip wheel || exit 1  # For RHEL/CentOS 7, because default pip is too old to build some packages.
        #pip install -U setuptools # update to latest version
        pip install -r requirements.txt || exit 1
    fi
}

configure_kubespray() {
    cd $BASEDIR/test/kubespray-test

    # copy offline repo playboo
    cp -r $BASEDIR/outputs/playbook/* ./

    set -x
    pwd
    if [ ! -d inventory/mycluster ]; then
        cp -rfp inventory/sample inventory/mycluster
    fi

    echo "===> Generate offline config"
    cat <<EOF >inventory/mycluster/group_vars/all/offline.yml
http_server: "http://$INSTALLER_IP:$NGINX_PORT"
registry_host: "$INSTALLER_IP:$REGISTRY_PORT"

containerd_insecure_registries: "{{ { registry_host: 'http://' + registry_host } }}"

nerdctl_extra_flags: " --insecure-registry"

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

runc_download_url: "{{ files_repo }}/runc/{{ runc_version }}/runc.{{ image_arch }}"
nerdctl_download_url: "{{ files_repo }}/nerdctl-{{ nerdctl_version }}-{{ ansible_system | lower }}-{{ image_arch }}.tar.gz"
containerd_download_url: "{{ files_repo }}/containerd-{{ containerd_version }}-linux-{{ image_arch }}.tar.gz"
EOF

    if [ -n "$INVENTORY" ] && [ -e "$BASEDIR/test/$INVENTORY" ]; then
        cp "$BASEDIR/test/$INVENTORY" inventory/mycluster/hosts.yaml
    else
        echo "===> Generate inventory"
        if [ "$ansible_in_container" != "true" ]; then
            CONFIG_FILE=inventory/mycluster/hosts.yaml python3 contrib/inventory_builder/inventory.py $IPS || exit 1
        else
            # TODO: can't pass CONFIG_FILE environment variable...
            py python3 contrib/inventory_builder/inventory.py $IPS || exit 1
            cp inventory/sample/hosts.yaml inventory/mycluster/hosts.yaml
        fi

        #echo "CONFIG_FILE=inventory/mycluster/hosts.yaml python3 contrib/inventory_builder/inventory.py $IPS" >builder.sh
        #/usr/local/bin/ansible-container.sh bash builder.sh
    fi
    cat inventory/mycluster/hosts.yaml
}

py() {
    if [ "$ansible_in_container" != "true" ]; then
        $*
    else
        $BASEDIR/outputs/ansible-playbook-inc.sh $*
    fi
}

do_kubespray() {
    cd $BASEDIR/test/kubespray-test

    cat <<EOF >ansible.cfg
[defaults]
log_path=ansible.log
EOF

    echo "===> Execute offline repo playbook"
    py ansible-playbook -i inventory/mycluster/hosts.yaml --become --become-user=root -e ansible_ssh_user=$(whoami) offline-repo.yml || exit 1

    echo "===> Execute kubespray"
    # Hack #8339
    #PULL_CMD="/usr/local/bin/nerdctl -n k8s.io pull --quiet --insecure-registry"
    py ansible-playbook -i inventory/mycluster/hosts.yaml  --become --become-user=root -e ansible_ssh_user=$(whoami) \
        -v -e "unsafe_show_logs=true" \
        cluster.yml \
        || exit 1
        #-e "image_pull_command='$PULL_CMD'" -e "image_pull_command_on_localhost='$PULL_CMD'" \
}

if [ "$ansible_in_container" != "true" ]; then
    prepare_pkgs
    venv
fi
prepare_kubespray
configure_kubespray
do_kubespray

mkdir ~/.kube
sudo cat /etc/kubernetes/admin.conf > ~/.kube/config
chmod 600 ~/.kube/config
