#!/bin/bash

# Mirror Docker CE repo: 
# This is deprecated.

source /etc/os-release

download() {
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
        mkdir -p outputs/rpms/
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
        mkdir -p outputs/debs/
        mv download.docker.com/linux/ubuntu outputs/debs/docker-ce
    fi

    /bin/rm -rf download.docker.com
}

prune_unused_versions() {
    if [ -e /etc/redhat-release ]; then
        DEST=outputs/rpms/docker-ce
    else
        DEST=outputs/debs/docker-ce
    fi

    for ver in 19.03.9 19.03.10 19.03.11 19.03.12 19.03.13 19.03.14 20.10.0 20.10.1 20.10.2 20.10.3 20.10.4 20.10.6; do
        find $DEST -name "docker-ce*${ver}*" -print -exec /bin/rm {} +
    done
}

download
prune_unused_versions
