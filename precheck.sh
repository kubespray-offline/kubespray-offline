#!/bin/bash

source ./config.sh

if ! command -v $docker >/dev/null 2>&1; then
    echo "No $docker installed"
    exit 1
fi
