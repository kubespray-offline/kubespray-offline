#!/bin/bash

source ./common.sh

prepare_pkgs
venv
prepare_kubespray
configure_kubespray
