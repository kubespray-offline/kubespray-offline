# How to test

## Preparation

Start up cluster using vagrant, using vagrant/ubuntu-cluster.

Run download-all.sh on installer node to download offile files.

## Deploy test

Re-create cluster using vagrant.

Login to installer node, then create ssh keypair and deploy public keys to target nodes.

    $ ssh-keygen
    $ ssh-copy-id 192.168.56.61
    $ ssh-copy-id 192.168.56.62

Then run `test-install-offline.sh` to run deployment test.
