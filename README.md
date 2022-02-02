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

- CentOS/RHEL 7/8
- Ubuntu 20.04

## Download offline files

Note: You must execute this process on same OS of k8s target nodes.

Before download offline files, check and edit configurations in config.sh.

Download all files:

    $ ./download-all.sh

All artifacts are stored in `./outputs` directory.

This script calls all of following scripts.

* prepare-docker.sh
    - Setup docker.
* prepare-pkgs.sh
    - Setup python, etc.
* prepare-venv.sh
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
* mirror-docker-ce.sh
    - Get mirror of docker-ce repository.
* copy-target-scripts.sh
    - Copy scripts for target node.

## Target node support scripts

Copy all contents in `outputs` directory to target node (which runs ansible).
Then run following scripts in `outputs` directory. 

* prepare.sh
    - Install docker-ce from local files.
    - Load nginx and registry images to docker.
* start-nginx.sh
    - Start nginx container.
* setup-offline.sh
    - Setup yum/deb repo config and PyPI mirror config to use local nginx server.
* start-registry.sh
    - Start docker private registry container.
* load-push-images.sh
    - Load all container images to docker.
    - Tag and push them to the private registry.

You can configure port number of nginx and private registry in config.sh.

## Deploy kubernetes using Kubespray

### Install required packages

Install required packages and python packages including ansible using local yum/deb repo and PyPI mirror.

For Ubuntu:

    $ sudo apt update
    $ sudo apt install -y python3-venv

Create and activate venv:

    # Example
    $ python3 -m venv ~/.venv/default
    $ source ~/.venv/default/bin/activate

Extract kubespray:

    $ tar xvzf kubespray-{version}.tar.gz
    $ cd kubespray-{version}

Install ansible:

    $ pip install -U pip                # update pip
    $ pip install -r requirements.txt   # Install ansible

### Create offline.yml

Create and place offline.yml file to your group_vars/all/offline.yml of your inventory directory.

You need to change `YOUR_HOST` with your registry/nginx host IP.

```yaml
# Registry overrides
kube_image_repo: "YOUR_HOST:35000"
gcr_image_repo: "YOUR_HOST:35000"
docker_image_repo: "YOUR_HOST:35000"
quay_image_repo: "YOUR_HOST:35000"

files_repo: "http://YOUR_HOST:8080/files"
yum_repo: "http://YOUR_HOST:8080/rpms"
ubuntu_repo: "http://YOUR_HOST:8080/debs"

kubeadm_download_url: "{{ files_repo }}/kubernetes/{{ kube_version }}/kubeadm"
kubectl_download_url: "{{ files_repo }}/kubernetes/{{ kube_version }}/kubectl"
kubelet_download_url: "{{ files_repo }}/kubernetes/{{ kube_version }}/kubelet"
# etcd is optional if you **DON'T** use etcd_deployment=host
etcd_download_url: "{{ files_repo }}/kubernetes/etcd/etcd-{{ etcd_version }}-linux-amd64.tar.gz"
cni_download_url: "{{ files_repo }}/kubernetes/cni/cni-plugins-linux-{{ image_arch }}-{{ cni_version }}.tgz"
crictl_download_url: "{{ files_repo }}/kubernetes/cri-tools/crictl-{{ crictl_version }}-{{ ansible_system | lower }}-{{ image_arch }}.tar.gz"
# If using Calico
calicoctl_download_url: "{{ files_repo }}/kubernetes/calico/{{ calico_ctl_version }}/calicoctl-linux-{{ image_arch }}"
# If using Calico with kdd
calico_crds_download_url: "{{ files_repo }}/kubernetes/calico/{{ calico_version }}.tar.gz"
```

Then run kubespray ansible playbook as usual.
