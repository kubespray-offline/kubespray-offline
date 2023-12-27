#!/bin/bash

source config.sh
source scripts/common.sh
source scripts/images.sh

# Apply pre-build patches
if [[ -d "./igz_patches/${KUBESPRAY_VERSION}-pre" ]]; then
  find ./igz_patches/${KUBESPRAY_VERSION}-pre/ -type f -exec patch --force --verbose -p1 -i {} \;
else
  echo "[INFO]: No igz pre-build patches provided for the current release ${KUBESPRAY_VERSION}"
fi
