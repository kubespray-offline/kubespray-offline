#!/bin/bash

cd $(dirname $0)

if [ ! -e iproute.bin ]; then
    echo "=> Save current route to 'iproute.bin'"
    sudo ip route save >iproute.bin
fi

echo "=> Remove default route"
sudo ip route del default
