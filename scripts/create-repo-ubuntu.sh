#!/bin/bash

. /etc/os-release

# Install prereqs
echo "===> Install prereqs"
sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release apt-utils 

# Package list
PKGS=$(cat pkglist/ubuntu/*.txt pkglist/ubuntu/${VERSION_ID}/*.txt | grep -v "^#" | sort | uniq)

CACHEDIR=cache/cache-debs
mkdir -p $CACHEDIR

echo "===> Update apt cache"
sudo apt update

# Resolve all dependencies
echo "===> Resolving dependencies"
DEPS=$(apt-cache depends --recurse --no-recommends --no-suggests --no-conflicts --no-breaks --no-replaces --no-enhances --no-pre-depends $PKGS | grep "^\w" | sort | uniq)

# Download packages
echo "===> Downloading packages: " $PKGS $DEPS
(cd $CACHEDIR && apt download $PKGS $DEPS)

# Create repo
echo "===> Creating repo"
DEBDIR=outputs/debs/local
if [ -e $DEBDIR ]; then
    /bin/rm -rf $DEBDIR
fi
mkdir -p $DEBDIR/pkgs
/bin/cp $CACHEDIR/* $DEBDIR/pkgs
/bin/rm $DEBDIR/pkgs/*i386.deb

pushd $DEBDIR || exit 1
apt-ftparchive sources . > Sources && gzip -c9 Sources > Sources.gz
apt-ftparchive packages . > Packages && gzip -c9 Packages > Packages.gz
apt-ftparchive contents . > Contents-amd64 && gzip -c9 Contents-amd64 > Contents-amd64.gz
apt-ftparchive release . > Release
popd

# Create tarball
#(cd outputs && mkdir -p offline-files && tar czf offline-files/offline-apt-repo.tar.gz debs)

echo "Done."
