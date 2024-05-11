#!/bin/bash

echo "==> prepare-pkgs.sh"

. /etc/os-release
. ./scripts/common.sh

# Install required packages
if [ -e /etc/redhat-release ]; then
    echo "==> Install required packages"
    $sudo yum check-update

    $sudo yum install -y rsync gcc libffi-devel createrepo podman || exit 1

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
            $sudo dnf install -y python3.11 python3.11-pip python3.11-devel || exit 1

            if ! command -v repo2module >/dev/null; then
                echo "==> Install modulemd-tools"
                $sudo dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
                $sudo dnf copr enable -y frostyx/modulemd-tools-epel
                $sudo dnf install -y modulemd-tools
            fi
            ;;
        9*)
            # RHEL 9
            $sudo dnf install -y python3.11 python3.11-pip python3.11-devel || exit 1

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
    $sudo apt -y install lsb-release curl gpg gcc libffi-dev rsync software-properties-common || exit 1

    case "$VERSION_ID" in
        20.04)
            # Prepare for podman
            echo "deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_${VERSION_ID}/ /" | $sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
            curl -SL https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable/xUbuntu_${VERSION_ID}/Release.key | $sudo apt-key add -

            # Prepare for latest python3
            sudo add-apt-repository ppa:deadsnakes/ppa -y || exit 1

            $sudo apt update
            $sudo apt install -y python3.11 python3.11-venv python3.11-dev podman || exit 1
            ;;
        *)
            $sudo apt install -y python3 python3-venv python3-dev podman || exit 1
            ;;
    esac
    $sudo apt install -y python3-pip python3-selinux
fi
