#!/bin/bash
if [ $# != 1 ]; then
    echo "Usage: $0 <target_host>"
    exit 1
fi

rsync -auv -e ssh outputs/ $1:outputs/
rsync -auv -e ssh test/ $1:test/
scp config.sh $1:
