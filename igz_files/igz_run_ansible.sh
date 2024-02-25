#!/bin/bash

# Make sure the container is not stuck from previous run
docker rm -f kubespray_ansible 2>/dev/null || true

docker run -u root:root \
    -v "${PWD}":/work \
    -v ~/.ssh:/root/.ssh \
    -v /etc/ssh:/etc/ssh \
    -v /etc/ansible/facts.d:/etc/ansible/facts.d \
    --name kubespray_ansible \
    --rm --entrypoint ansible-playbook \
    kubespray-offline-ansible:latest $*
    