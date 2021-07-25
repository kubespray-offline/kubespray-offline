#!/bin/bash

. /etc/os-release

# packages
PKGS=$(cat pkglist/rhel/*.txt pkglist/rhel/${VERSION_ID}/*.txt | grep -v "^#" | sort | uniq)

CACHEDIR=cache/cache-rpms
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

#echo "==> Create repo tarball"
#mkdir -p outputs/offline-files
#(cd outputs && tar cvzf offline-files/offline-rpm-repo.tar.gz rpms)

echo "create-repo done."
