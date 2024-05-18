#!/bin/bash

cd $(dirname $0)
source ./common.sh

run_in_docker ./download-all.sh
