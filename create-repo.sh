#!/bin/bash

if [ -e /etc/redhat-release ]; then
    ./scripts/create-repo-rhel.sh || exit 1
else
    ./scripts/create-repo-ubuntu.sh || exit 1
fi
