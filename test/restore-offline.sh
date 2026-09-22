#!/bin/bash

cd $(dirname $0)

DEFAULT_ROUTE_FILE=default-route.txt

if [ -s $DEFAULT_ROUTE_FILE ]; then
    echo "=> Restore default route from '$DEFAULT_ROUTE_FILE'"
    # Restored by device name (e.g. "default via 1.2.3.4 dev eth0 ..."), not
    # by the interface index `ip route save`/`restore` would use, so this
    # stays correct even if the NIC was torn down and recreated (e.g. by
    # netplan/systemd-networkd during package installs) while offline.
    sudo ip route add $(cat $DEFAULT_ROUTE_FILE) || true
else
    echo "=> No '$DEFAULT_ROUTE_FILE', do not restore routes"
fi
