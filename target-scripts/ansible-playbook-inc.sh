#!/bin/bash
# Run 'ansible-playbook' in container.

nerdctl=${nerdctl:-/usr/local/bin/nerdctl}
sudo=${sudo:-sudo}

$sudo $nerdctl run -it -v "${PWD}":/work -v ~/.ssh:/root/.ssh --rm kubespray-offline-ansible:latest $*
