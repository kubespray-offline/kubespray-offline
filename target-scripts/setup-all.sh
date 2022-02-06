#!/bin/bash

# prepare
./setup-container.sh || exit 1

# start web server
./start-nginx.sh || exit 1

# setup local repositories
./setup-offline.sh || exit 1

# setup python
./setup-py.sh || exit 1

# start private registry
./start-registry.sh || exit 1

# load and push all images to registry
./load-push-all-images.sh || exit 1
