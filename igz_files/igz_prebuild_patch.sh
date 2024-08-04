#!/bin/bash

# Override config.sh
cat igz_files/igz_config.sh >> config.sh
cat igz_files/igz_config.sh >> target-scripts/config.sh

source config.sh
source scripts/common.sh
source scripts/images.sh

# Apply pre-build patches
echo "===> Looking for pre-build patches for version ${KUBESPRAY_VERSION}"
if [[ -d "./igz_patches/${KUBESPRAY_VERSION}-pre" ]]; then
  echo "$(ls -la ./igz_patches/${KUBESPRAY_VERSION}-pre)"
  echo "===> Applying ${KUBESPRAY_VERSION}-pre patches"
  find ./igz_patches/${KUBESPRAY_VERSION}-pre/ -type f -exec patch --force --verbose -p1 -i {} \;
else
  echo "[INFO]: No igz pre-build patches provided for the current release ${KUBESPRAY_VERSION}"
fi
