# Kubespray offline file generator scripts

## What's this?

This is offline support scripts for [Kubespray offline environment](https://kubespray.io/#/docs/offline-environment).

This supports:

* Download offline files.
    - Download Yum/Deb repository files for OS packages.
    - Download all container images used by Kubespray.
    - Download PyPI mirror files for Kubespray.
* Support scripts for target node.
    - Install containerd from local file.
    - Start up nginx container as web server to supply Yum/Deb repository and PyPI mirror.
    - Start up docker private registry.
    - Load all container images and push them to the private registry.

## Requirements

- RHEL 8 / AlmaLinux 8
- Ubuntu 20.04 / 22.04

## Download offline files

Note: You must execute this process on same OS of k8s target nodes.

Before download offline files, check and edit configurations in `config.sh`.

If you don't have container runtime (docker or containerd), install it first.

* To use Docker CE
    - run `install-docker.sh` to install Docker CE.
* To use containerd
    - run `install-containerd.sh` to install containerd and nerdctl.
    - Set `docker` environment variable to `/usr/local/bin/nerdctl` in `config.sh`.

Then, download all files:

    $ ./download-all.sh

All artifacts are stored in `./outputs` directory.

This script calls all of following scripts.

* prepare-pkgs.sh
    - Setup python, etc.
* prepare-py.sh
    - Setup python venv, install required python packages.
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

Copy all contents in `outputs` directory to target node (which runs ansible).
Then run following scripts in `outputs` directory. 

* setup-container.sh
    - Install containerd from local files.
    - Load nginx and registry images to containerd.
* start-nginx.sh
    - Start nginx container.
* setup-offline.sh
    - Setup yum/deb repo config and PyPI mirror config to use local nginx server.
* setup-py.sh
    - Install python3 and venv from local repo.
* start-registry.sh
    - Start docker private registry container.
* load-push-images.sh
    - Load all container images to containerd.
    - Tag and push them to the private registry.
* extract-kubespray.sh
    - Extract kubespray tarball and apply all patches.

You can configure port number of nginx and private registry in config.sh.

## Deploy kubernetes using Kubespray

### Install required packages

Create and activate venv:

    # Example
    $ python3 -m venv ~/.venv/default
    $ source ~/.venv/default/bin/activate

Note: For Ubuntu 20.04 and RHEL/CentOS 8, you need to use python 3.9.
    
    # Example
    $ python3.9 -m venv ~/.venv/default
    $ source ~/.venv/default/bin/activate

Extract kubespray and apply patches:

    $ ./extract-kubespray.sh
    $ cd kubespray-{version}

For Ubuntu 22.04, you need to install build tools to build some python packages.

    $ sudo apt install gcc python3-dev libffi-dev libssl-dev

Install ansible:

    $ pip install -U pip                # update pip
    $ pip install -r requirements.txt   # Install ansible

### Create offline.yml

Copy [offline.yml](./offline.yml) file to your group_vars/all/offline.yml of your inventory directory, and edit it.

You need to change `YOUR_HOST` with your registry/nginx host IP.

Notes:

* `runc_donwload_url` differ from kubespray official document, and must include `runc_version`.
* The insecure registries configurations of containerd was changed from kubespray 2.23.0. You need to set `containerd_registries_mirrors` instead of `containerd_insecure_registries`. 
* You need to set `nerdctl_image_pull_command` for workaround of insecure registries from kubespray 2.24.0.

### Deploy offline repo configurations

Deploy offline repo configurations which use your yum_repo/ubuntu_repo to all target nodes using ansible.

First, copy offline setup playbook to kubespray directory. 

    $ cp -r ${outputs_dir}/playbook ${kubespray_dir}

Then execute `offline-repo.yml` playbook.

    $ cd ${kubespray_dir}
    $ ansible-playbook -i ${your_inventory_file} offline-repo.yml

### Run kubespray

Run kubespray ansible playbook.

    # Example  
    $ ansible-playbook -i inventory/mycluster/hosts.yaml  --become --become-user=root cluster.yml
