#!/bin/bash

echo "==> prepare-pkgs.sh"

. /etc/os-release
. ./scripts/common.sh

# Install required packages
if [ -e /etc/redhat-release ]; then
    echo "==> Install required packages"
    $sudo yum check-update

    $sudo yum install -y rsync gcc libffi-devel createrepo || exit 1

    case "$VERSION_ID" in
        7*)
            # RHEL/CentOS 7
            echo "FATAL: RHEL/CentOS 7 is not supported anymore."
            exit 1
            # Install python 3.8 from SCL
            #if [ "$ID" == "centos" ]; then
            #    # CentOS 7
            #    $sudo yum-config-manager --enable centos-sclo-rh || exit 1
            #    $sudo yum install centos-release-scl -y || exit 1
            #else
            #    # RHEL 7
            #    $sudo subscription-manager repos --enable rhel-server-rhscl-7-rpms || exit 1
            #fi
            #$sudo yum install -y rh-python38 rh-python38-python-devel || exit 1
            ;;
        8*)
            # RHEL/CentOS 8
            $sudo yum install -y python39 python39-pip python39-devel || exit 1

            if ! command -v repo2module >/dev/null; then
                echo "==> Install modulemd-tools"
                $sudo dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
                $sudo dnf copr enable -y frostyx/modulemd-tools-epel
                $sudo dnf install -y modulemd-tools
            fi
            ;;
        9*)
            # RHEL 9
            if ! command -v repo2module >/dev/null; then
                $sudo dnf install -y modulemd-tools
            fi
            ;;
        *)
            echo "Unknown version_id: $VERSION_ID"
            exit 1
            ;;
    esac
else
    $sudo apt update
    if [ "$1" == "--upgrade" ]; then
        $sudo apt upgrade
    fi
    $sudo apt -y install lsb-release curl gpg python3 || exit 1
    $sudo apt install -y python3 python3-pip python3-venv python3-selinux rsync || exit 1
    $sudo apt install -y gcc python3-dev libffi-dev || exit 1 # pypi-mirror
fi
