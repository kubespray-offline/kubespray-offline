#!/bin/bash

./prepare.sh || exit 1
./kubespray.sh || exit 1

echo "Done"

