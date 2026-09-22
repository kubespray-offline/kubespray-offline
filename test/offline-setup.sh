#!/bin/bash

BASEDIR=$(cd $(dirname $0)/..; pwd)
TESTDIR=$BASEDIR/test

# Go to outputs dir
cd $BASEDIR/outputs
source ./config.sh

prepare_ssh_key() {
    if [ ! -e ~/.ssh/id_rsa ]; then
        ssh-keygen -f ~/.ssh/id_rsa -N "" && cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
    fi
}

prepare_servers() {
    #set -x

    # Remove default route to emulate offline
    $TESTDIR/go-offline.sh

    # setup
    ./setup-all.sh || exit 1

    # Restore default route
    $TESTDIR/restore-offline.sh

    # No local image cleanup needed here anymore: load-push-all-images.sh
    # pushes straight from the tar.gz archives to the registry via skopeo,
    # so these images never touch local containerd storage, and nginx/
    # registry are reloaded idempotently by setup-container.sh on the next
    # run. Re-pushing to the registry is idempotent too (existing blobs are
    # skipped), so there's nothing to reset between test runs.
    #set +x
}

prepare_ssh_key
prepare_servers
