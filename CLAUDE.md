# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Project Does

This project generates offline installation artifacts for [Kubespray](https://kubespray.io/) — a Kubernetes deployment tool. It downloads all required files (OS packages, container images, binary files, PyPI packages) on an internet-connected machine, then provides scripts to serve them locally on an air-gapped target cluster.

Supported OS: RHEL/AlmaLinux/Rocky Linux 9, Ubuntu 22.04/24.04. The current Kubespray version target is set in `target-scripts/config.sh` (`KUBESPRAY_VERSION`).

## Key Configuration

- **`target-scripts/config.sh`** — primary configuration file (Kubespray version, containerd/nerdctl/runc versions, registry port, nginx version). This file is sourced by both the download scripts (via `config.sh`) and the target node scripts.
- **`config.sh`** (root) — sources `target-scripts/config.sh` and sets the container runtime (`docker` variable, defaults to `podman`).
- **`imagelists/images.txt`** — additional container images to download beyond what Kubespray's `generate_list.sh` produces.

## Download Workflow (internet-connected node)

```bash
./download-all.sh          # runs all steps below in order
```

Steps in order:
1. `prepare-pkgs.sh` — installs podman, python, etc.
2. `prepare-py.sh` — sets up Python venv.
3. `get-kubespray.sh` — downloads and extracts Kubespray tarball to `./cache/kubespray-<VERSION>/`.
4. `pypi-mirror.sh` — mirrors PyPI packages.
5. `download-kubespray-files.sh` — calls Kubespray's `contrib/offline/generate_list.sh` to get file/image lists, then downloads binaries and container images to `outputs/`.
6. `download-additional-containers.sh` — downloads images listed in `imagelists/*.txt`.
7. `create-repo.sh` — downloads RPM or DEB packages via `scripts/create-repo-rhel.sh` or `scripts/create-repo-ubuntu.sh`.
8. `copy-target-scripts.sh` — copies `target-scripts/*` into `outputs/`.

All artifacts land in `./outputs/`. Images are stored as gzipped tarballs in `outputs/images/`.

To skip re-downloading images: `SKIP_DOWNLOAD_IMAGES=true ./download-all.sh`

## Running in Docker (for CI / cross-OS testing)

Docker images are named `tmurakam/kubespray-offline-<target>` where target is one of: `alma8`, `alma9`, `rocky9`, `rocky10`, `ubuntu22`, `ubuntu24`.

```bash
# Build a Docker image for a target OS
./docker/build-image.sh rocky9
./docker/build-image.sh --push rocky9   # also push to Docker Hub

# Run full download inside Docker
./docker/download-all.sh rocky9

# Run CI test inside Docker
./docker/ci-test-in-docker.sh rocky9
```

`docker/common.sh` mounts the repo root, Docker socket, and containerd socket into the container.

## Target Node Workflow (air-gapped node)

Copy `outputs/` to the target node, then run from that directory:

```bash
./setup-all.sh             # runs all steps below
# or individually:
./setup-container.sh       # install containerd, load nginx/registry images
./start-nginx.sh           # start nginx serving files/packages/pypi
./setup-offline.sh         # configure yum/deb repos and pip to use local nginx
./setup-py.sh              # install python from local repo
./start-registry.sh        # start private Docker registry on REGISTRY_PORT (default 35000)
./load-push-all-images.sh  # load all images into containerd, tag and push to local registry
./extract-kubespray.sh     # extract kubespray tarball and apply patches
```

## CI Testing

`ci-test/ci-test.sh` runs from the `outputs/` directory: it sets up offline repos (yum or deb), configures pip mirror, extracts Kubespray, sets up Python venv, and installs Ansible — all offline. This validates that the downloaded artifacts are self-sufficient.

```bash
# Run CI test locally (must be run from outputs/ directory or via docker wrapper)
./docker/ci-test-in-docker.sh rocky9
```

## Kubespray Patches

`target-scripts/patches/<KUBESPRAY_VERSION>/` contains `.patch` files applied automatically by `extract-kubespray.sh` after extracting the tarball.

## offline.yml

`offline.yml` is a sample Kubespray group_vars file. Copy it to your inventory's `group_vars/all/offline.yml` and replace `YOUR_HOST` with the nginx/registry host IP. Key points:

- `registry_host` defaults to port 35000.
- Use `containerd_registries_mirrors` (not the old `containerd_insecure_registries`) for insecure registry config (required since Kubespray 2.23.0).
- `runc_download_url` must include `runc_version` in the path.

## Output Directory Structure

```
outputs/
  images/          # container images as .tar.gz + images.list
  files/           # binary files organized by component (kubernetes/, calico/, runc/, etc.)
  pypi/            # PyPI mirror
  rpms/ or debs/   # OS package repo
  playbook/        # offline-repo.yml ansible playbook
  *.sh             # target node scripts (copied from target-scripts/)
  config.sh        # config (copied from target-scripts/)
```
