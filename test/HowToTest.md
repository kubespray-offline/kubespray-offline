# How to test

## Preparation

Start up cluster using vagrant. The Vagrantfile exists in `vagrant/singles` or `vagrant/cluster`.

Login to the installer node (VM), run `install-docker.sh` and `download-all.sh`
download all offline files.

## Deploy test

Destroy and re-create the cluster using vagrant.

### Single node test

Login to installer node, then execute `test-install-offline.sh` to run deployment test.

### Multi nodes cluster test

Login to installer node, then create ssh keypair and deploy public keys to target nodes.

    $ ./setup-ssh-keys.sh

Set inventory file for cluster.

    $ export INVENTORY=hosts-cluster.yaml

Then execute `test-install-offline.sh` to run deployment test.
