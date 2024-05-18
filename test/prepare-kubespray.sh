#!/bin/bash

source ./common.sh

prepare_pkgs
source ../target-scripts/venv.sh
prepare_kubespray
configure_kubespray
