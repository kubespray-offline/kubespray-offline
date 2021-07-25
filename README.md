# Kubespray offline file generator scripts

## Requirements

Same OS of k8s target nodes.

- CentOS/RHEL 7/8
- Ubuntu 20.04

## Preparation

Install required packages.

    $ ./prepare.sh

Download and extract kubespray.

    $ ./get-kubespray.sh

Activate python3 venv

    $ . ~/.venv/default/bin/activate

## Download Kubespray offline files

Set KUBESPRAY_DIR environment variable to kubespray directory,
or just prepare kubespray in ./kubespray dir.

Execute download files of kubespray

    $ ./download-kubespray-files.sh

## Download additional container images

Download additional container images.
You can add any container image repoTag to imagelists/*.txt.

    $ ./download-additional-containers.sh

## Download RPM/DEB repositories

    $ ./create-repo.sh

## Download PyPI mirror files

    $ ./pypi-mirror.sh

