#!/bin/bash

run() {
    echo "=> Running: $*"
    $* || {
        echo "Failed in : $*"
        exit 1
    }
}

# prepare
run ./setup-container.sh

# start web server
run ./start-nginx.sh

# setup local repositories
run ./setup-offline.sh

# setup python
run ./setup-py.sh

# start private registry
run ./start-registry.sh

# load and push all images to registry
run ./load-push-all-images.sh
