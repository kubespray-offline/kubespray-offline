#!/bin/bash

run() {
    echo "=> Running: $*"
    $* || {
        echo "Failed in : $*"
        exit 1
    }
}

source ./config.sh

#run ./install-docker.sh
#run ./install-nerdctl.sh
run ./precheck.sh
run ./prepare-pkgs.sh || exit 1
run ./prepare-py.sh
run ./get-kubespray.sh
if $ansible_in_container; then
    run ./build-ansible-container.sh
else
    run ./pypi-mirror.sh
fi
run ./download-kubespray-files.sh
run ./download-additional-containers.sh
run ./create-repo.sh
run ./copy-target-scripts.sh

echo "Done."
