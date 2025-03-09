#!/bin/bash

cd $(dirname $0)

if [ -e iproute.bin ]; then
    echo "=> Restore default route from 'iproute.bin'"
    sudo ip route restore <iproute.bin
else
    echo "=> No 'iproute.bin', do not restore routes"
fi
