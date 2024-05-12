#!/bin/bash

export LANG=C  # avoid ansible unsupported lang error

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

BASEDIR=$(cd $(dirname $0)/..; pwd)
source $BASEDIR/config.sh
source $BASEDIR/outputs/config.sh

KUBESPRAY_TARBALL=kubespray-${KUBESPRAY_VERSION}.tar.gz

cd $BASEDIR/test

prepare_pkgs() {
    if [ "${NAME}" = "Ubuntu" ] && [ "${VERSION_ID}" = "22.04" ]; then
        sudo apt install -y gcc python3-dev libffi-dev # libssl-dev
    fi
}

prepare_kubespray() {
    # extract kubespray
    cd $BASEDIR/outputs
    ./extract-kubespray.sh || exit 1

    [ -e $BASEDIR/test/kubespray-test ] && /bin/rm -rf $BASEDIR/test/kubespray-test
    mv kubespray-${KUBESPRAY_VERSION} $BASEDIR/test/kubespray-test

    cd $BASEDIR/test/kubespray-test
    
    # install ansible
    #pip install -U setuptools # adhoc: update to intermediate version
    pip install -U pip wheel || exit 1  # For RHEL/CentOS 7, because default pip is too old to build some packages.
    #pip install -U setuptools # update to latest version
    pip install -r requirements.txt || exit 1
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
    cat $BASEDIR/offline.yml \
        | sed "s/^http_server:.*/http_server: \"http:\/\/$INSTALLER_IP\"/" \
        | sed "s/^registry_host:.*/registry_host: \"$INSTALLER_IP:$REGISTRY_PORT\"/" \
              >inventory/mycluster/group_vars/all/offline.yml

    cat inventory/mycluster/group_vars/all/offline.yml

    if [ -n "$INVENTORY" ] && [ -e "$BASEDIR/test/$INVENTORY" ]; then
        cp "$BASEDIR/test/$INVENTORY" inventory/mycluster/hosts.yaml
    else
        echo "===> Generate inventory"
        CONFIG_FILE=inventory/mycluster/hosts.yaml python3 contrib/inventory_builder/inventory.py $IPS || exit 1

        #echo "CONFIG_FILE=inventory/mycluster/hosts.yaml python3 contrib/inventory_builder/inventory.py $IPS" >builder.sh
        #/usr/local/bin/ansible-container.sh bash builder.sh
    fi
    cat inventory/mycluster/hosts.yaml
}

do_kubespray() {
    cd $BASEDIR/test/kubespray-test

#    cat <<EOF >ansible.cfg
#[defaults]
#log_path=ansible.log
#EOF

    echo "===> Execute offline repo playbook"
    ansible-playbook -i inventory/mycluster/hosts.yaml  --become --become-user=root offline-repo.yml || exit 1

    echo "===> Execute kubespray"
    # Hack #8339
    #PULL_CMD="/usr/local/bin/nerdctl -n k8s.io pull --quiet --insecure-registry"
    ansible-playbook -i inventory/mycluster/hosts.yaml  --become --become-user=root \
        -v -e "unsafe_show_logs=true" \
        cluster.yml \
        || exit 1
        #-e "image_pull_command='$PULL_CMD'" -e "image_pull_command_on_localhost='$PULL_CMD'" \
}
