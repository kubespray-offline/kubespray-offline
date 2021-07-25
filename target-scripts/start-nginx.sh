#!/bin/bash

BASEDIR="."
if [ ! -d images ] && [ -d ../outputs ]; then
  BASEDIR="../outputs"  # for tests
fi
BASEDIR=$(cd $BASEDIR; pwd)

NGINX_IMAGE=nginx:1.19

sudo docker run -d \
    -p 8080:80 \
    --restart always \
    --name nginx \
    -v ${BASEDIR}:/usr/share/nginx/html \
    ${NGINX_IMAGE}
