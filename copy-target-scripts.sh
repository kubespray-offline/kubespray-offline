#!/bin/bash
umask 022

echo "==> Copy target scripts"
/bin/cp -f -r target-scripts/* outputs/
