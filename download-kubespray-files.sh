#!/bin/bash

FILES_DIR=outputs/files
IMAGES_DIR=outputs/images

get_url() {
    url=$1
    filename="${url##*/}"

    if [ ! -e $FILES_DIR/$filename ]; then
        echo "==> Download $url"
        curl -SL $url > $FILES_DIR/$filename
    else
        echo "==> Skip $url"
    fi
}

get_image() {
    image=$1

    filename="$(echo ${image} | sed s@"/"@"-"@g | sed s/":"/"-"/g)".tar

    if [ ! -e $IMAGES_DIR/$filename ]; then
        echo "==> Pull $image"
        sudo docker pull $image || exit 1
        sudo docker save -o $IMAGES_DIR/$filename $image
    else
        echo "==> Skip $image"
    fi
}

KUBESPRAY_DIR=${KUBESPRAY_DIR:-./kubespray}
if [ ! -e $KUBESPRAY_DIR ]; then
    echo "No kubespray dir at $KUBESPRAY_DIR"
    exit 1
fi

# execute offline generate_list.sh
/bin/bash ${KUBESPRAY_DIR}/contrib/offline/generate_list.sh || exit 1

mkdir -p $FILES_DIR
mkdir -p $IMAGES_DIR

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
