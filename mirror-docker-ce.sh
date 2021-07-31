#!/bin/bash

source /etc/os-release

/bin/rm -rf download.docker.com

if [ -e /etc/redhat-release ]; then
    type=centos
    wget --mirror --no-parent \
         https://download.docker.com/linux/${type}/${VERSION_ID}/x86_64/stable/   # need last slash for --no-parent

    curl -SL https://download.docker.com/linux/${type}/gpg >download.docker.com/linux/${type}/gpg

    /bin/rm -rf outputs/rpms/docker-ce
    mv download.docker.com/linux/${type} outputs/rpms/docker-ce
else
    # Ubuntu
    wget --mirror --no-parent \
         -X linux/ubuntu/dists/focal/pool/edge \
         -X linux/ubuntu/dists/focal/pool/nightly \
         -X linux/ubuntu/dists/focal/pool/test \
         -X linux/ubuntu/dists/focal/pool/stable/arm64 \
         -X linux/ubuntu/dists/focal/pool/stable/ppc64el \
         -X linux/ubuntu/dists/focal/pool/stable/s390x \
         https://download.docker.com/linux/ubuntu/dists/${VERSION_CODENAME}/   # need last slash for --no-parent

    curl -SL https://download.docker.com/linux/ubuntu/ >download.docker.com/linux/ubuntu/gpg

    /bin/rm -rf outputs/debs/docker-ce
    mv download.docker.com/linux/ubuntu outputs/debs/docker-ce
fi

/bin/rm -rf download.docker.com

