#!/bin/bash
if [ -z "$docker" ]; then
    docker=docker
    if [ -e /usr/local/bin/nerdctl ]; then
        docker=/usr/local/bin/nerdctl
    fi
fi

sudo $docker run -it -u $(id -u):$(id -g) \
    -v "${PWD}":/work -v ~/.ssh:/root/.ssh \
    --rm kubespray-offline-ansible:latest $*
