#!/bin/bash

. /etc/os-release

REQUIRE_MODULE=false

VERSION_MAJOR=$VERSION_ID
case "${VERSION_MAJOR}" in
    8*)
        REQUIRE_MODULE=true
        VERSION_MAJOR=8
        ;;
    9*)
        REQUIRE_MODULE=true
        VERSION_MAJOR=9
        ;;
    10*)
        VERSION_MAJOR=10
        ;;
    *)
        echo "Unsupported version: $VERSION_MAJOR"
        ;;
esac

# packages
PKGS=$(cat pkglist/rhel/*.txt pkglist/rhel/${VERSION_MAJOR}/*.txt | grep -v "^#" | sort | uniq)

CACHEDIR=cache/cache-rpms
mkdir -p $CACHEDIR

RT="sudo dnf download --resolve --alldeps --downloaddir $CACHEDIR"

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

#Wait a second to avoid error on Vagrant
sleep 1

if $REQUIRE_MODULE; then
    cd $RPMDIR
    #createrepo_c . || exit 1
    echo "==> repo2module"
    LANG=C repo2module -s stable . modules.yaml || exit 1
    echo "==> modifyrepo"
    modifyrepo_c --mdtype=modules modules.yaml repodata/ || exit 1
fi

echo "create-repo done."
