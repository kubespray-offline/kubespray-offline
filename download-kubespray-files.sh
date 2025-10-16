#!/bin/bash

umask 022

source ./config.sh
source scripts/common.sh
source scripts/images.sh

KUBESPRAY_DIR=./cache/kubespray-${KUBESPRAY_VERSION}
if [ ! -e $KUBESPRAY_DIR ]; then
    echo "No kubespray dir at $KUBESPRAY_DIR"
    exit 1
fi

FILES_DIR=outputs/files

# Decide relative directory of file from URL
#
# kubernetes/vx.x.x        : kubeadm/kubectl/kubelet
# kubernetes/etcd          : etcd
# kubernetes/cni           : CNI plugins
# kubernetes/cri-tools     : crictl
# kubernetes/calico/vx.x.x : calico
# kubernetes/calico        : calicoctl
# runc/vx.x.x              : runc
# cilium-cli/vx.x.x        : cilium-cli
# gvisor/{ver}/{arch}      : gvisor (sunrc, containerd-shim)
# scopeo/vx.x.x            : scopeo
# yq/vx.x.x                : yq
#
decide_relative_dir() {
    local url=$1
    local rdir
    rdir=$url
    rdir=$(echo $rdir | sed "s@.*/\(v[0-9.]*\)/.*/kube\(adm\|ctl\|let\)@kubernetes/\1@g")
    rdir=$(echo $rdir | sed "s@.*/etcd-.*.tar.gz@kubernetes/etcd@")
    rdir=$(echo $rdir | sed "s@.*/cni-plugins.*.tgz@kubernetes/cni@")
    rdir=$(echo $rdir | sed "s@.*/crictl-.*.tar.gz@kubernetes/cri-tools@")
    rdir=$(echo $rdir | sed "s@.*/\(v.*\)/calicoctl-.*@kubernetes/calico/\1@")
    rdir=$(echo $rdir | sed "s@.*/\(v.*\)/runc.amd64@runc/\1@")
    rdir=$(echo $rdir | sed "s@.*/\(v.*\)/cilium-linux-.*@cilium-cli/\1@")
    rdir=$(echo $rdir | sed "s@.*/\([^/]*\)/\([^/]*\)/runsc@gvisor/\1/\2@")
    rdir=$(echo $rdir | sed "s@.*/\([^/]*\)/\([^/]*\)/containerd-shim-runsc-v1@gvisor/\1/\2@")
    rdir=$(echo $rdir | sed "s@.*/\(v[^/]*\)/skopeo-linux-.*@skopeo/\1@")
    rdir=$(echo $rdir | sed "s@.*/\(v[^/]*\)/yq_linux_*@yq/\1@")
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
        for i in {1..3}; do
            curl --location --show-error --fail --output $FILES_DIR/$rdir/$filename $url && return
            echo "curl failed. Attempt=$i"
        done
        echo "Download failed, exit : $url"
        exit 1
    else
        echo "==> Skip $url"
    fi
}

# execute offline generate_list.sh
generate_list() {
    #if [ $KUBESPRAY_VERSION == "2.18.0" ]; then
    #    export containerd_version=${containerd_version:-1.5.8}
    #    export host_os=linux
    #    export image_arch=amd64
    #fi
    LANG=C /bin/bash ${KUBESPRAY_DIR}/contrib/offline/generate_list.sh || exit 1

    #if [ $KUBESPRAY_VERSION == "2.18.0" ]; then
    #    # check roles/download/default/main.yml to decide version
    #    snapshot_controller_tag=${snapshot_controller_tag:-v4.2.1}
    #    sed -i "s@\(.*/snapshot-controller:\)@\1${snapshot_controller_tag}@" ${KUBESPRAY_DIR}/contrib/offline/temp/images.list || exit 1
    #fi
}

. ./target-scripts/venv.sh

generate_list

mkdir -p $FILES_DIR

cp ${KUBESPRAY_DIR}/contrib/offline/temp/files.list $FILES_DIR/
cp ${KUBESPRAY_DIR}/contrib/offline/temp/images.list $IMAGES_DIR/

# --- Add Cilium Helm chart to files.list (derive version) ---
# 1) Try from images.list (when generator was run with cilium)
CILIUM_VER="$(grep -Eo 'quay\.io/cilium/cilium:v[0-9]+\.[0-9]+\.[0-9]+' "${IMAGES_DIR}/images.list" | head -n1 | awk -F: '{print $3}')"

# 2) Fallback: read cilium_version from Kubespray defaults
if [ -z "${CILIUM_VER}" ]; then
  # Path valid for your pinned commit
  DL_YML="${KUBESPRAY_DIR}/roles/kubespray_defaults/defaults/main/download.yml"
  # If it ever moves, also try:
  [ -f "${DL_YML}" ] || DL_YML="${KUBESPRAY_DIR}/roles/download/defaults/main.yml"
  if [ -f "${DL_YML}" ]; then
    CILIUM_VER="$(grep -E '^[[:space:]]*cilium_version:' "${DL_YML}" | awk '{print $2}' | tr -d "\"'")"
    # Ensure it has the leading v (many defaults are like 1.18.1 without v)
    [[ "${CILIUM_VER}" =~ ^v ]] || CILIUM_VER="v${CILIUM_VER}"
  fi
fi

CILIUM_VER_NO_V="${CILIUM_VER#v}"
CHART_URL="https://helm.cilium.io/cilium-${CILIUM_VER_NO_V}.tgz"

if [ -n "${CILIUM_VER_NO_V}" ]; then
  # ensure trailing newline so grep -qx works reliably
  tail -c1 "${FILES_DIR}/files.list" | read -r _ || echo >> "${FILES_DIR}/files.list"
  # append only once
  if ! grep -qx "${CHART_URL}" "${FILES_DIR}/files.list"; then
    echo "${CHART_URL}" >> "${FILES_DIR}/files.list"
    echo "Added Cilium chart ${CHART_URL} to files.list"
  fi
  
  # --- Add Cilium operator-generic image to images.list ---
  # Kubespray generates cilium/operator but Cilium expects cilium/operator-generic
  GENERIC_OPERATOR_IMAGE="quay.io/cilium/operator-generic:${CILIUM_VER}"
  # ensure trailing newline so grep -qx works reliably
  tail -c1 "${IMAGES_DIR}/images.list" | read -r _ || echo >> "${IMAGES_DIR}/images.list"
  # append only once
  if ! grep -qx "${GENERIC_OPERATOR_IMAGE}" "${IMAGES_DIR}/images.list"; then
    echo "${GENERIC_OPERATOR_IMAGE}" >> "${IMAGES_DIR}/images.list"
    echo "Added Cilium operator-generic image ${GENERIC_OPERATOR_IMAGE} to images.list"
  fi
else
  echo "Skip adding Cilium chart and operator-generic image: could not determine cilium_version"
fi

# download files
files=$(cat ${FILES_DIR}/files.list)
for i in $files; do
    get_url $i
done

# download images
./download-images.sh || exit 1
