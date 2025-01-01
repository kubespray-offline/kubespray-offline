#!/bin/bash

source ./config.sh

BASEDIR="."
if [ ! -d images ] && [ -d ../outputs ]; then
    BASEDIR="../outputs"  # for tests
fi
BASEDIR=$(cd $BASEDIR; pwd)

NGINX_IMAGE=nginx:1.27.3

echo "===> Start nginx"
sudo /usr/local/bin/nerdctl run -d \
    --network host \
    --restart always \
    --name nginx \
    -v ${BASEDIR}:/usr/share/nginx/html \
    -v ${BASEDIR}/nginx-default.conf:/etc/nginx/conf.d/default.conf \
    ${NGINX_IMAGE} || exit 1
