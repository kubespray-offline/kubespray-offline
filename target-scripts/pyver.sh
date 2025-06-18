#!/bin/bash
# Select python version

. /etc/os-release

# Python version
PY=3.11

if [ -e /etc/redhat-release ]; then
    case "$VERSION_ID" in
        7*)
            # RHEL/CentOS 7
            echo "FATAL: RHEL/CentOS 7 is not supported anymore."
            exit 1
            ;;
        8*|9*)
            ;;
        10*)
            PY=3.12            
            ;;
        *)
            echo "Unknown version_id: $VERSION_ID"
            exit 1
            ;;
    esac
else
    case "$VERSION_ID" in
        20.04|22.04)
            ;;

        24.04)
           PY=3.12
           ;;
    esac
fi
