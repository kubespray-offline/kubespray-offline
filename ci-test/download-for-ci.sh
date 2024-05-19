#!/bin/bash

# Download without container images for CI test

cd $(dirname $0)/..

run() {
    echo "=> Test: Running: $*"
    $* || {
        echo "Failed in : $*"
        exit 1
    }
}

run ./precheck.sh
run ./prepare-pkgs.sh
run ./prepare-py.sh
run ./get-kubespray.sh
run ./pypi-mirror.sh

export SKIP_DOWNLOAD_IMAGES=true
run ./download-kubespray-files.sh
#run ./download-additional-containers.sh

run ./create-repo.sh
run ./copy-target-scripts.sh
