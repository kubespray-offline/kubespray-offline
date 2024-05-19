#!/bin/bash

BASE_DIR=$(cd $(dirname $0)/..; pwd)
OUTPUTS_DIR="${BASE_DIR}/outputs"

echo "outputs dir = ${OUTPUTS_DIR}"
cd ${OUTPUTS_DIR}

run() {
    echo "=> Test: Running: $*"
    $* || {
        echo "Failed in : $*"
        exit 1
    }
}

# setup yum/deb repository
setup_yum_repos() {
    sudo /bin/rm /etc/yum.repos.d/offline.repo

    echo "===> Disable all yumrepositories"
    for repo in /etc/yum.repos.d/*.repo; do
        #sudo sed -i "s/^enabled=.*/enabled=0/" $repo
        sudo mv "${repo}" "${repo}.original"
    done

    echo "===> Setup local yum repository"
    cat <<EOF | sudo tee /etc/yum.repos.d/offline.repo
[offline-repo]
name=Offline repo
baseurl=file://${OUTPUTS_DIR}/rpms/local/
enabled=1
gpgcheck=0
EOF
}

# setup yum/deb repository
setup_deb_repos() {
    echo "===> Copy offline repository to /tmp"
    /bin/cp -r ${OUTPUTS_DIR}/debs /tmp/
    ls -lR /tmp/debs/local

    echo "===> Setup deb offline repository"
    cat <<EOF | sudo tee /etc/apt/apt.conf.d/99offline
APT::Get::AllowUnauthenticated "true";
Acquire::AllowInsecureRepositories "true";
Acquire::AllowDowngradeToInsecureRepositories "true";
EOF

    cat <<EOF | sudo tee /etc/apt/sources.list.d/offline.list
deb [trusted=yes] file:///tmp/debs/local/ ./
EOF

    echo "===> Disable default repositories"
    if [ ! -e /etc/apt/sources.list.original ]; then
        sudo cp /etc/apt/sources.list /etc/apt/sources.list.original
    fi
    sudo sed -i "s/^deb /# deb /" /etc/apt/sources.list
}

setup_pypi_mirror() {
    # PyPI mirror
    echo "===> Setup PyPI mirror"
    mkdir -p ~/.config/pip/
    cat <<EOF >~/.config/pip/pip.conf
[global]
index = file://${OUTPUTS_DIR}/pypi/
index-url = file://${OUTPUTS_DIR}/pypi/
trusted-host = localhost
EOF
}

# Test: Try to install containerd
#run ./install-containerd.sh

# Setup offline
if [ -e /etc/redhat-release ]; then
    setup_yum_repos
else
    setup_deb_repos
fi
setup_pypi_mirror

# Test: Extract kubespray
run ./extract-kubespray.sh

# Test: setup python
run ./setup-py.sh

# Test: create venv
source ./venv.sh

# Test: install ansible
source ./config.sh
pip install -r kubespray-${KUBESPRAY_VERSION}/requirements.txt

echo "ci-test done."
