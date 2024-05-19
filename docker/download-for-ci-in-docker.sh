#!/bin/bash

cd $(dirname $0)
source ./common.sh

run_in_docker ./ci-test/download-for-ci.sh

