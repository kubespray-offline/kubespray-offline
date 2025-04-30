#!/bin/bash

if [[ $# != 1 ]]; then
  echo "Usage: $0 <host>"
  exit 1
fi
host=$1

TEST_DIR=$(pwd)

cmd() {
    echo "Run: '$1'"
    vagrant ssh $host -c "$1" || exit 1
}

phase1() {
    cd $TEST_DIR/vagrant/singles || exit 1
    echo "====> Vagrant up $host"
    vagrant up $host || exit 1

    echo "====> Install docker"
    cmd "cd kubespray-offline && ./install-docker.sh"

    echo
    echo
    echo "====> Execute download-all.sh"
    cmd "cd kubespray-offline && ./download-all.sh"

    echo
    echo
    echo "====> Destroy $host"
    vagrant destroy -f $host || exit 1
}

phase2() {
    cd $TEST_DIR/vagrant/singles || exit 1
    echo "====> Vagrant up $host"
    vagrant up $host || exit 1

    echo
    echo
    echo "====> Execute test-install-offline.sh"
    cmd "cd kubespray-offline/test && ./test-install-offline.sh"

    echo "====> Check status"
    cmd "kubectl get node -o wide"
    cmd "kubectl get pod -o wide -A"
}

phase1
phase2

echo
echo
echo "Done."
