#!/bin/bash

source ./config.sh

BASEDIR="."
if [ ! -d images ] && [ -d ../outputs ]; then
    BASEDIR="../outputs"  # for tests
fi
BASEDIR=$(cd $BASEDIR; pwd)
NERDCTL="sudo /usr/local/bin/nerdctl"

NGINX_IMAGE=nginx:${NGINX_VERSION}

echo "===> Stop nginx"
$NERDCTL container update --restart no nginx 2>/dev/null
$NERDCTL container stop nginx 2>/dev/null
$NERDCTL container rm nginx 2>/dev/null

echo "===> Start nginx"
$NERDCTL container run -d \
    --network host \
    --restart always \
    --name nginx \
    -v ${BASEDIR}:/usr/share/nginx/html \
    -v ${BASEDIR}/nginx-default.conf:/etc/nginx/conf.d/default.conf \
    ${NGINX_IMAGE} || exit 1
