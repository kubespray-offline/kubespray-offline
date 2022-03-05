#!/bin/bash
if [ $# -lt 1 ]; then
    echo "usage: $0 <target> [-s]"
    exit 1
fi
target=$1
if [ "$2" != "-s" ]; then
    /bin/rm -rf cache/cache-* outputs/rpms output/debs

    vagrant up $target || exit 1
    vagrant ssh $target -c "cd kubespray-offline && ./install-docker.sh && ./download-all.sh" || exit 1
    vagrant destroy -f $target || exit 1
else
    echo "Skip build."
fi

vagrant up $target || exit 1
vagrant ssh $target -c "cd kubespray-offline/test && ./test-install-offline.sh"
