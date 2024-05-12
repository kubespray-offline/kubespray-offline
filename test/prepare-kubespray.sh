#!/bin/bash

source ./common.sh

prepare_pkgs
source ../scripts/venv.sh
prepare_kubespray
configure_kubespray
