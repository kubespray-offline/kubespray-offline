#!/bin/bash

sudo=
if [ "$EUID" -ne 0 ]; then
    sudo=sudo
fi
