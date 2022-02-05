#!/bin/bash

source ./config.sh

# setup yum/deb repository
setup_yum_repos() {
    echo "===> Disable all yumrepositories"
    for repo in /etc/yum.repos.d/*.repo; do
        #sudo sed -i "s/^enabled=.*/enabled=0/" $repo
        sudo mv "${repo}" "${repo}.original"
    done
        
    echo "===> Setup local yum repository"
    cat <<EOF | sudo tee /etc/yum.repos.d/local-repo.repo  # override installed by prepare.sh
[local-repo]
name=Local repo
baseurl=http://localhost:$NGINX_PORT/rpms/local/
enabled=1
gpgcheck=0
EOF
}

# setup yum/deb repository
setup_deb_repos() {
    echo "===> Setup deb offline repository"
    cat <<EOF | sudo tee /etc/apt/apt.conf.d/99offline
APT::Get::AllowUnauthenticated "true";
Acquire::AllowInsecureRepositories "true";
Acquire::AllowDowngradeToInsecureRepositories "true";
EOF

    cat <<EOF | sudo tee /etc/apt/sources.list.d/local-repo.list
deb [trusted=yes] http://localhost:$NGINX_PORT/debs/local/ ./
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
index = http://localhost:$NGINX_PORT/pypi/
index-url = http://localhost:$NGINX_PORT/pypi/
trusted-host = localhost
EOF
}

if [ -e /etc/redhat-release ]; then
    setup_yum_repos
else
    setup_deb_repos
fi
setup_pypi_mirror
