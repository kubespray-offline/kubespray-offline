# Kubespray offline file generator scripts

## What's this?

This is offline support scripts for [Kubespray offline environment](https://kubespray.io/#/docs/offline-environment).

This supports:

* Download offline files.
    - Download Yum/Deb repository files for OS packages.
    - Download all container images used by Kubespray.
    - Download PyPI mirror files for Kubespray.
* Support scripts for target node.
    - Install docker-ce from local file.
    - Start up nginx container as web server to supply Yum/Deb repository and PyPI mirror.
    - Start up docker private registry.
    - Load all container images and push them to the private registry.

## Requirements

Same OS of k8s target nodes.

- CentOS/RHEL 7/8
- Ubuntu 20.04

## Download offline files

Before download offline files, check and edit configurations in config.sh.

Download all files:

    $ ./download-all.sh

All artifacts are stored in ./outputs directory. Copy it to target node.

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
* copy-target-scripts.sh
    - Copy scripts for target node.

## Target node support scripts

You can configure port of nginx and private registry in config.sh.

* prepare.sh
    - Install docker-ce from local files.
    - Load nginx and registry images to docker.
* start-nginx.sh
    - Start nginx container.
* start-registry.sh
    - Start docker private registry container.
* load-push-images.sh
    - Load all container images to docker.
    - Tag and push them to the private registry.
