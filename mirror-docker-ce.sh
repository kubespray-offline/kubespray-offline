#!/bin/bash

source /etc/os-release

/bin/rm -rf download.docker.com

if [ -e /etc/redhat-release ]; then
    type=centos

    # Remove version minor of RHEL
    if echo "$VERSION_ID" | grep "^8\."; then
        VERSION_ID=8
    elif echo "$VERSION_ID" | grep "^7\."; then
        VERSION_ID=7
    fi

    wget --mirror --no-parent \
         https://download.docker.com/linux/${type}/${VERSION_ID}/x86_64/stable/   # need last slash for --no-parent

    curl -SL https://download.docker.com/linux/${type}/gpg >download.docker.com/linux/${type}/gpg || exit 1

    /bin/rm -rf outputs/rpms/docker-ce
    mv download.docker.com/linux/${type} outputs/rpms/docker-ce
else
    # Ubuntu
    wget --mirror --no-parent \
         -X linux/ubuntu/dists/${VERSION_CODENAME}/pool/edge \
         -X linux/ubuntu/dists/${VERSION_CODENAME}/pool/nightly \
         -X linux/ubuntu/dists/${VERSION_CODENAME}/pool/test \
         -X linux/ubuntu/dists/${VERSION_CODENAME}/pool/stable/arm64 \
         -X linux/ubuntu/dists/${VERSION_CODENAME}/pool/stable/ppc64el \
         -X linux/ubuntu/dists/${VERSION_CODENAME}/pool/stable/s390x \
         https://download.docker.com/linux/ubuntu/dists/${VERSION_CODENAME}/   # need last slash for --no-parent

    curl -SL https://download.docker.com/linux/ubuntu/gpg >download.docker.com/linux/ubuntu/gpg || exit 1

    /bin/rm -rf outputs/debs/docker-ce
    mv download.docker.com/linux/ubuntu outputs/debs/docker-ce
fi

/bin/rm -rf download.docker.com

