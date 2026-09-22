#!/bin/bash

cd $(dirname $0)

DEFAULT_ROUTE_FILE=default-route.txt

if [ ! -e $DEFAULT_ROUTE_FILE ]; then
    echo "=> Save current default route to '$DEFAULT_ROUTE_FILE'"
    ip -4 route show default | head -1 > $DEFAULT_ROUTE_FILE
fi

echo "=> Remove default route"
sudo ip route del default
