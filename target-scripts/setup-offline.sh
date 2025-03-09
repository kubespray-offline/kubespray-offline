#!/bin/bash

# Setup offline repo for ansible node.

source ./config.sh
source /etc/os-release

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
baseurl=http://localhost/rpms/local/
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

    cat <<EOF | sudo tee /etc/apt/sources.list.d/offline.list
deb [trusted=yes] http://localhost/debs/local/ ./
EOF

    case "$VERSION_ID" in
        "20.04"|"22.04")
            echo "===> Disable default repositories"
            if [ ! -e /etc/apt/sources.list.original ]; then
                sudo cp /etc/apt/sources.list /etc/apt/sources.list.original
            fi
            sudo sed -i "s/^deb /# deb /" /etc/apt/sources.list
            ;;

        *)
            echo "===> Disable default repositories"
            if [ ! -e /etc/apt/sources.list.d/ubuntu.sources.original ]; then
                sudo cp /etc/apt/sources.list.d/ubuntu.sources /etc/apt/sources.list.d/ubuntu.sources.original
            fi
            sudo /bin/rm /etc/apt/sources.list.d/ubuntu.sources
            sudo touch /etc/apt/sources.list.d/ubuntu.sources
            ;;
    esac

}


setup_pypi_mirror() {
    # PyPI mirror
    echo "===> Setup PyPI mirror"
    mkdir -p ~/.config/pip/
    cat <<EOF >~/.config/pip/pip.conf
[global]
index = http://localhost/pypi/
index-url = http://localhost/pypi/
trusted-host = localhost
EOF
}

if [ -e /etc/redhat-release ]; then
    setup_yum_repos
else
    setup_deb_repos
fi
setup_pypi_mirror
