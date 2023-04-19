#!/bin/bash

# Exit on any error
set -e
. config.sh

CURRENT_DIR=$(pwd)
KUBESPRAY_DIR=./cache/kubespray-${KUBESPRAY_VERSION}
# Current dir already has a slash at the end - don't fix the line below
PATCH_DIR=${CURRENT_DIR}target-scripts/patches/${KUBESPRAY_VERSION}

# Get some basic stuff
./precheck.sh
./prepare-pkgs.sh
./prepare-py.sh
./get-kubespray.sh
./pypi-mirror.sh

echo "===> Fetching requirements.txt"
ls -la $KUBESPRAY_DIR
cp $KUBESPRAY_DIR/requirements.txt .
ls -la .

# We need to break the flow to set kube_version and apply the required patches

if [[ ! -d "${PATCH_DIR}" ]]; then
  mkdir -p ${PATCH_DIR}
fi

if [[ -d "./igz_patches/${KUBESPRAY_VERSION}" ]]; then
  find ./igz_patches/${KUBESPRAY_VERSION}/ -type f -exec cp {} $PATCH_DIR/ \;
else
  echo "[WARNING]: No patches provided for the current release ${KUBESPRAY_VERSION}!"
fi

# Check pathes dir
declare -a patches

for file in "$PATCH_DIR"/*; do
  if [[ -f "$file" && "${file##*.}" != "patch" ]]; then
    echo "File $file does not have a .patch extension. Exiting."
    exit 1
  else
    echo "Found patch file $file"
    patches+=("$file")
  fi
done

# We apply the patches here mostly because of kube_version.patch otherwise the script will work on the default k8s version for current release
# Apply all patches
for patch in "${patchArray[@]}"; do
  pushd $KUBESPRAY_DIR
  patch --force --verbose -p1 < $patch || exit 1
  popd
done

# Continue with the flow
./download-kubespray-files.sh
./create-repo.sh
./copy-target-scripts.sh
#./download-additional-containers.sh

echo " ===> Fetch Iguazio scripts"

# Copy Iguazio files
find . -path './proc' -prune -o -type f -name "igz_*" -exec cp {} /outputs/ \;

# Set Kubespray version for deployment script
echo "KUBESPRAY_VERSION=\${KUBESPRAY_VERSION:-${KUBESPRAY_VERSION}}" >> /outputs/igz_config.sh

# This does not fall under any category
echo " ===> Fetch helper patches"
cp ./igz_patches/nvidia/config.toml.patch /outputs
cp ./igz_patches/ansible_cfg/ansible.cfg.patch /outputs

chown -R 1000:1000 /outputs

echo "<=== Kubespray $KUBESPRAY_VERSION is ready for offline deployment ===>"
exit 0
