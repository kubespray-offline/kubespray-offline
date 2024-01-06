#!/bin/bash

./prepare-test.sh || exit 1
./prepare-kubespray.sh || exit 1
./do-kubespray.sh || exit 1

echo "Done"

