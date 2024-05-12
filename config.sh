#!/bin/bash

source ./target-scripts/config.sh

# container runtime for preparation node
docker=${docker:-podman}
#docker=${docker:-docker}
#docker=${docker:-/usr/local/bin/nerdctl}

# Run ansible in container?
ansible_in_container=${ansible_in_container:-false}
