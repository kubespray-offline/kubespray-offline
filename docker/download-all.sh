#!/bin/bash

cd $(dirname $0)
source ./common.sh

run_in_docker "SKIP_DOWNLOAD_IMAGES=false ./download-all.sh"

sudo chown -R $(id -u):$(id -g) ../outputs ../cache

