#!/bin/bash

BASEDIR="."
if [ ! -d images ] && [ -d ../outputs ]; then
    BASEDIR="../outputs"  # for tests
fi

BASEDIR=$(cd $BASEDIR; pwd)

cd $BASEDIR

# Install docker-ce
install_docker() {
    if ! command -v docker >/dev/null; then
        if [ -e /etc/redhat-release ]; then
            cd $BASEDIR/rpms/local

            # Install local yum repo
            cat <<EOF | sudo tee /etc/yum.repos.d/local-repo.repo
[local-repo]
name=Local repo
baseurl=file://$(pwd)
enabled=0
gpgcheck=0
EOF

            # Install docker-ce, etc
            sudo yum install -y --disablerepo="*" --enablerepo=local-repo docker-ce || exit 1
            # gcc python3-devel libffi-devel openssl-devel
        else
            cd $BASEDIR/debs/local/pkgs
            sudo dpkg -i docker-ce*.deb containerd*.deb || exit 1
        fi
    fi

    sudo systemctl enable --now docker
}

# Install containerd
install_containerd() {
    # Install runc
    sudo cp ./files/runc.amd64 /usr/local/bin/runc
    sudo chmod 755 /usr/local/bin/runc
    
    # Install nerdctl
    tar xvf ./files/nerdctl-*.tar.gz -C /tmp
    sudo cp /tmp/nerdctl /usr/local/bin
    
    # Install containerd
    sudo tar xvf ./files/containerd-*.tar.gz --strip-components=1 -C /usr/local/bin
    sudo cp ./containerd.service /etc/systemd/system/

    sudo mkdir -p \
         /etc/systemd/system/containerd.service.d \
         /etc/containerd \
         /var/lib/containerd \
         /run/containerd

    sudo cp config.toml /etc/containerd/

    sudo systemctl daemon-reload
    sudo systemctl enable --now containerd

    # Install cni plugins
    sudo mkdir -p /opt/cni/bin
    sudo tar xvzf ./files/kubernetes/cni/cni-plugins-.*.tgz -C /opt/cni/bin
}

#install_docker
install_containerd

# Load images
cd $BASEDIR/images
gunzip -c docker.io-library-registry-*.tar.gz | sudo nerdctl load
gunzip -c docker.io-library-nginx-*.tar.gz | sudo nerdctl load
