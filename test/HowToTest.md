# How to test

## Preparation

Start up cluster using vagrant, using vagrant/ubuntu-cluster.

Run download-all.sh on installer node to download offile files.

## Deploy test

Re-create cluster using vagrant.

### Single node test

Login to installer node, then execute `test-install-offline.sh` to run deployment test.

### Multi nodes cluster test

Login to installer node, then create ssh keypair and deploy public keys to target nodes.

    $ ssh-keygen -N ""
    $ ssh-copy-id 192.168.56.60
    $ ssh-copy-id 192.168.56.61
    $ ssh-copy-id 192.168.56.62

Set inventory file for cluster.

    $ export INVENTORY=cluster.yaml

Then execute `test-install-offline.sh` to run deployment test.
