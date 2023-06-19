#!/bin/bash

. /etc/os-release

VERSION_MAJOR=$VERSION_ID
case "${VERSION_MAJOR}" in
    7*)
        VERSION_MAJOR=7
        ;;
    8*)
        VERSION_MAJOR=8
        ;;
    9*)
        VERSION_MAJOR=9
        ;;
    *)
        echo "Unsupported version: $VERSION_MAJOR"
        ;;
esac

# packages
PKGS=$(cat pkglist/rhel/*.txt pkglist/rhel/${VERSION_MAJOR}/*.txt | grep -v "^#" | sort | uniq)

CACHEDIR=cache/cache-rpms
mkdir -p $CACHEDIR

IS_RHEL8=false
if [ "$VERSION_MAJOR" = "7" ]; then
    RT="sudo repotrack -a x86_64 -p $CACHEDIR"
else
    # RHEL 8
    IS_RHEL8=true
    RT="sudo dnf download --resolve --alldeps --downloaddir $CACHEDIR"
fi

#YD="yumdownloader --destdir=$CACHEDIR -y"

echo "==> Downloading: " $PKGS
$RT $PKGS || {
    echo "Download error"
    exit 1
}

# create rpms dir
RPMDIR=outputs/rpms/local
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
