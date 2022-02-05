#!/bin/bash
if [ $# -ne 1 ]; then
    echo "usage: $0 <target>"
    exit 1
fi
target=$1

/bin/rm -rf cache/cache-* outputs/rpms output/debs

vagrant up $target || exit 1
vagrant ssh $target -c "cd kubespray-offline && ./download-all.sh" || exit 1
vagrant destroy -f $target || exit 1

vagrant up $target || exit 1
vagrant ssh $target -c "cd kubespray-offline/test && ./test-install-offline.sh"


