#!/bin/bash

source config.sh
source scripts/images.sh

if [ ! -e $KUBESPRAY_DIR ]; then
    echo "No kubespray dir at $KUBESPRAY_DIR"
    exit 1
fi

FILES_DIR=outputs/files

# Decide relative directory of file from URL
decide_relative_dir() {
    local url=$1
    local rdir
    rdir=$url
    rdir=$(echo $rdir | sed "s@.*/\(v[0-9.]*\)/.*/kube\(adm\|ctl\|let\)@kubernetes/\1@g")
    rdir=$(echo $rdir | sed "s@.*/etcd-.*.tar.gz@kubernetes/etcd@")
    rdir=$(echo $rdir | sed "s@.*/cni-plugins.*.tgz@kubernetes/cni@")
    rdir=$(echo $rdir | sed "s@.*/crictl-.*.tar.gz@kubernetes/cri-tools@")
    rdir=$(echo $rdir | sed "s@.*/\(v.*\)/calicoctl-.*@kubernetes/calico/\1@")
    if [ "$url" != "$rdir" ]; then
        echo $rdir
        return
    fi

    rdir=$(echo $rdir | sed "s@.*/calico/.*@kubernetes/calico@")
    if [ "$url" != "$rdir" ]; then
        echo $rdir
    else
        echo ""
    fi
}

get_url() {
    url=$1
    filename="${url##*/}"

    rdir=$(decide_relative_dir $url)

    if [ -n "$rdir" ]; then
        if [ ! -d $FILES_DIR/$rdir ]; then
            mkdir -p $FILES_DIR/$rdir
        fi
    else
        rdir="."
    fi

    if [ ! -e $FILES_DIR/$rdir/$filename ]; then
        echo "==> Download $url"
        curl -SL $url > $FILES_DIR/$rdir/$filename
    else
        echo "==> Skip $url"
    fi
}

# execute offline generate_list.sh
/bin/bash ${KUBESPRAY_DIR}/contrib/offline/generate_list.sh || exit 1

mkdir -p $FILES_DIR

cp ${KUBESPRAY_DIR}/contrib/offline/temp/files.list $FILES_DIR/
cp ${KUBESPRAY_DIR}/contrib/offline/temp/images.list $IMAGES_DIR/

# download files
files=$(cat ${FILES_DIR}/files.list)
for i in $files; do
    get_url $i
done

# download images
images=$(cat ${IMAGES_DIR}/images.list)
for i in $images; do
    get_image $i
done

# Copy kubespray itself
if [ ! -e ${KUBESPRAY_TARBALL} ]; then
    ./get-kubespray.sh
fi
cp ${KUBESPRAY_TARBALL} ${FILES_DIR}
