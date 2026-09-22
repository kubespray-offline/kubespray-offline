# How to test

You can run a single VM test with `FULL-TEST-SINGLE.sh`.

## Phase 1: Preparation

Download all offline files (excludes container images) to local disk using Docker.

    $ ../cleanup.sh
    $ ../docker/download-all.sh ubuntu24

Note: Vagrant with libvirt will not work because synced_folder supports only one-way sync of rsync.

Then, download container images.

    $ cd ..
    $ ./download-kubespray-files.sh

## Phase 2: Deploy test

Destroy and re-create the cluster using vagrant.

Start up cluster using vagrant. The Vagrantfile exists in `vagrant/singles` or `vagrant/cluster`.

For ubuntu 24.04:

    $ cd vagrant/singles
    $ vagrant destroy -f
    $ vagrant up ubuntu24

### Single node test

Login to installer node, then execute `test-install-offline.sh` to run deployment test.

### Multi nodes cluster test

Login to installer node, then create ssh keypair and deploy public keys to target nodes.

    $ ./setup-ssh-keys.sh

Set inventory file for cluster.

    $ export INVENTORY=hosts-cluster.yaml

Then execute `test-install-offline.sh` to run deployment test.
