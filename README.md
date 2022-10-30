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

- RHEL 7 / CentOS 7
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

Note: For RHEL/CentOS 7, you need to use python 3.8.
    
    # Example
    $ /opt/rh/rh-python38/root/usr/bin/python -m venv ~/.venv/default
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

Create and place offline.yml file to your group_vars/all/offline.yml of your inventory directory.

You need to change `YOUR_HOST` with your registry/nginx host IP.

```yaml
http_server: "http://YOUR_HOST/"
registry_host: "YOUR_HOST:35000"

containerd_insecure_registries: # Kubespray #8340
  "YOUR_HOST:35000": "http://YOUR_HOST:35000"

files_repo: "{{ http_server }}/files"
yum_repo: "{{ http_server }}/rpms"
ubuntu_repo: "{{ http_server }}/debs"

# Registry overrides
kube_image_repo: "{{ registry_host }}"
gcr_image_repo: "{{ registry_host }}"
docker_image_repo: "{{ registry_host }}"
quay_image_repo: "{{ registry_host }}"

# Download URLs: See roles/download/defaults/main.yml of kubespray.
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

runc_download_url: "{{ files_repo }}/runc/{{ runc_version }}/runc.{{ image_arch }}"
nerdctl_download_url: "{{ files_repo }}/nerdctl-{{ nerdctl_version }}-{{ ansible_system | lower }}-{{ image_arch }}.tar.gz"
containerd_download_url: "{{ files_repo }}/containerd-{{ containerd_version }}-linux-{{ image_arch }}.tar.gz"
```

Note: `runc_donwload_url` differ from kubespray official document, and must include `runc_version`.

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
