#!/bin/bash

. /etc/os-release

IS_OFFLINE=${IS_OFFLINE:-true}

# Install python and dependencies
echo "===> Install python, venv, etc"
if [ -e /etc/redhat-release ]; then
    # RHEL
    DNF_OPTS=
    if [[ $IS_OFFLINE = "true" ]]; then
        DNF_OPTS="--disablerepo=* --enablerepo=offline-repo"
    fi
    #sudo dnf install -y $DNF_OPTS gcc libffi-devel openssl-devel || exit 1

    if [[ "$VERSION_ID" =~ ^7.* ]]; then
        echo "FATAL: RHEL/CentOS 7 is not supported anymore."
        exit 1
    #elif [[ "$VERSION_ID" =~ ^8.* ]]; then
    #elif [[ "$VERSION_ID" =~ ^9.* ]]; then
    #else
    fi
    sudo dnf install -y $DNF_OPTS python3.11 || exit 1
    #sudo dnf install -y $DNF_OPTS python3.11-devel || exit 1
else
    # Ubuntu
    sudo apt update
    PY=3.11
    case "$VERSION_ID" in
        20.04)
            if [ "${IS_OFFLINE}" = "false" ]; then
                # Prepare for latest python3
                sudo apt install -y software-properties-common
                sudo add-apt-repository ppa:deadsnakes/ppa -y || exit 1
                sudo apt update
            fi
            ;;
        24.04)
            PY=3.12
            ;;
    esac
    #sudo apt install -y python${PY}-dev gcc libffi-dev libssl-dev || exit 1
    sudo apt install -y python${PY}-venv || exit 1
fi
