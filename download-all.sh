#!/bin/bash

./prepare.sh || exit 1
./get-kubespray.sh || exit 1
./pypi-mirror.sh || exit 1
./download-kubespray-files.sh || exit 1
./download-additional-containers.sh || exit 1
./create-repo.sh || exit 1
./copy-target-scripts.sh || exit 1

echo "Done."
