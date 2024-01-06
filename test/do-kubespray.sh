#!/bin/bash

source ./common.sh

venv
do_kubespray

mkdir ~/.kube
sudo cat /etc/kubernetes/admin.conf > ~/.kube/config
chmod 600 ~/.kube/config
