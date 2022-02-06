#!/bin/bash

./prepare-test.sh || exit 1
./kubespray.sh || exit 1

echo "Done"

