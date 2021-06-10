# Kubespray offline file generator scripts

## Requirements

Same OS of k8s target nodes.

- CentOS/RHEL 7/8
- Ubuntu 20.04

## Preparation

Install required packages.

    $ ./prepare.sh

## Download Kubespray offline files

Set KUBESPRAY_DIR environment variable to kubespray directory,
or just prepare kubespray in ./kubespray dir.

Active python3 venv

    $ . ~/.venv/default/bin/activate

Install kubespray required packages including ansible.

    $ pip install -r $KUBESPRAY_DIR/requirements.txt

Create invetory directory.

    $ cp -rfp $KUBESPRAY_DIR/inventory/sample $KUBESPRAY_DIR/inventory/mycluster

Execute download tasks of kubespray.

    $ ./kubespray-download.sh
