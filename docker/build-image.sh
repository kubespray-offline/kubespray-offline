#!/bin/bash

OPTS=""
#OPTS="--progress=plain --no-cache=true"

docker build -f Dockerfile.cent8 -t kubespray-offline-cent8:latest $OPTS ..

docker build -f Dockerfile.ubuntu2004 -t kubespray-offline-ubuntu2004:latest $OPTS ..
