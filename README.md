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

## Download offline files

You can set KUBESPRAY_DIR environment variable to kubespray directory,
or download kubespray automatically.

Download all files:

    $ ./download-all.sh

This script calls all of following scripts.

* prepare.sh
    - Setup docker, python venv, etc.
* get-kubespray.sh
    - Download and extract kubespray, if KUBESPRAY_DIR does not exist.
* pypi-mirror.sh
    - Download PyPI mirror files
* download-kubespray-files.sh
    - Download kubespray offline files (containers, files, etc)
* download-additional-containers.sh
    - Download additional containers.
    - You can add any container image repoTag to imagelists/*.txt.
* create-repo.sh
    - Download RPM or DEB repositories.
