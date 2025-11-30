#!/bin/bash

# Do offline setup
# Create ssh keys, execute 'setup-all.sh' in offline state.
./offline-setup.sh || exit 1

# Configure kubespray
./prepare-kubespray.sh || exit 1

# Run kubespray to deploy k8s cluster
./do-kubespray.sh || exit 1

echo "Done"

