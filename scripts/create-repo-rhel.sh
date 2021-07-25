#!/bin/bash

. /etc/os-release

# packages
PKGS=$(cat pkglist/rhel/*.txt pkglist/rhel/${VERSION_ID}/*.txt | grep -v "^#" | sort | uniq)

CACHEDIR=cache/cache-rpms
mkdir -p $CACHEDIR

IS_RHEL8=false
if [ "$VERSION_ID" = "7" ]; then
    RT="sudo repotrack -a x86_64 -p $CACHEDIR"
else
    # RHEL 8
    IS_RHEL8=true
    RT="sudo dnf download --resolve --alldeps --downloaddir $CACHEDIR"

    # Install EPEL8
    if ! command -v repo2module >/dev/null; then
        echo "==> Install modulemd-tools"
        sudo dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
        sudo dnf copr enable -y frostyx/modulemd-tools-epel
        sudo dnf install -y modulemd-tools
    fi
fi

YD="yumdownloader --destdir=$CACHEDIR -y"

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

echo "==> createrepo"
createrepo $RPMDIR || exit 1

#echo "==> Create repo tarball"
#mkdir -p outputs/offline-files
#(cd outputs && tar cvzf offline-files/offline-rpm-repo.tar.gz rpms)

if $IS_RHEL8; then
    cd $RPMDIR
    #createrepo_c . || exit 1
    echo "==> repo2module"
    LANG=C repo2module -s stable . modules.yaml || exit 1
    echo "==> modifyrepo"
    modifyrepo_c --mdtype=modules modules.yaml repodata/ || exit 1
fi

echo "create-repo done."
