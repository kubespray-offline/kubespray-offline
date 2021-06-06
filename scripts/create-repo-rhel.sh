#!/bin/bash

. /etc/os-release

# packages
PKGS=$(cat pkglist/rhel/*.txt pkglist/rhel/${VERSION_ID}/*.txt | grep -v "^#" | sort | uniq)

# Docker CE
echo "==> Setup docker-ce repo"
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo rpm -e podman-docker docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine

# install tools
if ! type createrepo >/dev/null 2>&1; then
    echo "==> Install createrepo"
    sudo yum install -y createrepo || exit 1
fi
if ! type repotrack >/dev/null 2>&1; then
    echo "==> Install yum-utils"
    sudo yum install -y yum-utils || exit 1
fi

CACHEDIR=outputs/cache-rpms
mkdir -p $CACHEDIR

if [ "$VERSION_ID" = "7" ]; then
    RT="sudo repotrack -a x86_64 -p $CACHEDIR"
else
    RT="sudo dnf download --resolve --alldeps --downloaddir $CACHEDIR"
fi

YD="sudo yumdownloader --destdir=$CACHEDIR -y"

echo "==> Downloading: " $PKGS
$RT $PKGS || (echo "Download error" && exit 1)

# create rpms dir
RPMDIR=outputs/rpms
if [ -e $RPMDIR ]; then
    /bin/rm -rf $RPMDIR || exit 1
fi
mkdir -p $RPMDIR
/bin/cp $CACHEDIR/*.rpm $RPMDIR/
/bin/rm $RPMDIR/*.i686.rpm

sudo createrepo $RPMDIR || exit 1

echo "==> Create repo tarball"
mkdir -p outputs/offline-files
(cd outputs && tar cvzf offline-files/offline-rpm-repo.tar.gz rpms)

echo "create-repo done."
