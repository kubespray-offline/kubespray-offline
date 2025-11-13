# Kubespray offline file generator scripts

## Table of Contents

- [What's this?](#whats-this)
- [Quick Start](#quick-start)
- [System Requirements](#system-requirements)
- [Prerequisites](#prerequisites)
- [Download offline files (Preparation Node)](#download-offline-files-preparation-node)
- [Target Node Setup](#target-node-setup)
- [Deploy Kubernetes using Kubespray](#deploy-kubernetes-using-kubespray)
- [Verification](#verification)
- [Troubleshooting](#troubleshooting)

## What's this?

This is offline support scripts for [Kubespray offline environment](https://kubespray.io/#/docs/operations/offline-environment).

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

## Quick Start

For experienced users, here's the condensed workflow:

```bash
# On preparation node (must be same OS as target)
./download-all.sh                    # Downloads everything to ./outputs/

# Copy outputs/ to target node, then:
cd outputs/
./setup-container.sh && ./start-nginx.sh && ./setup-offline.sh
./setup-py.sh && ./start-registry.sh && ./load-push-images.sh
./extract-kubespray.sh

# Deploy Kubernetes
python3.11 -m venv ~/.venv/3.11 && source ~/.venv/3.11/bin/activate
cd kubespray-2.29.0 && pip install -U pip && pip install -r requirements.txt
cp ../offline.yml inventory/mycluster/group_vars/all/
# Edit offline.yml: Replace YOUR_HOST with your IP
cp -r ../playbook .
ansible-playbook -i inventory/mycluster/hosts.yaml offline-repo.yml
ansible-playbook -i inventory/mycluster/hosts.yaml --become cluster.yml
```

## System Requirements

### Supported Operating Systems

- **RHEL / AlmaLinux / Rocky Linux**: 9.x or later
- **Ubuntu**: 22.04 / 24.04

**Important**: RHEL 8 support is dropped from Kubespray 2.29.0.

### Hardware Requirements

#### Preparation Node (Download Phase)
- **CPU**: 2+ cores recommended
- **RAM**: 4GB+ recommended
- **Disk Space**:
  - Minimum: 30GB free space
  - Recommended: 50GB+ free space
  - Varies based on Kubernetes version and number of images

#### Target Node (Kubernetes Node)
- Refer to [Kubespray requirements](https://github.com/kubernetes-sigs/kubespray#requirements)
- Additional space for local registry and nginx: 20-30GB

### Network Requirements

#### Preparation Node
- Internet access required for downloading:
  - Container images from public registries (docker.io, gcr.io, quay.io, etc.)
  - OS packages from official repositories
  - PyPI packages
  - Kubespray release files from GitHub

#### Target Node
- No internet access required (air-gapped environment supported)
- Network connectivity between nodes for Kubernetes cluster communication

## Prerequisites

### 1. Check OS Version

**RHEL/AlmaLinux/Rocky Linux:**
```bash
cat /etc/redhat-release
# Expected output: AlmaLinux release 9.x or Rocky Linux release 9.x
```

**Ubuntu:**
```bash
lsb_release -a
# Expected: Ubuntu 22.04 or 24.04
```

### 2. Verify Disk Space

Check available disk space:
```bash
df -h .
# Ensure at least 30GB free in current directory
```

Check disk space for output directory:
```bash
df -h /path/to/outputs
```

### 3. Check User Permissions

Ensure you have sudo/root privileges:
```bash
sudo -v
# Should not prompt for password or accept your password
```

### 4. Verify Internet Connectivity (Preparation Node Only)

Test connectivity to required registries:
```bash
# Test Docker Hub
curl -I https://registry-1.docker.io/v2/ 2>/dev/null | head -n 1

# Test Google Container Registry
curl -I https://gcr.io/v2/ 2>/dev/null | head -n 1

# Test Quay.io
curl -I https://quay.io/v2/ 2>/dev/null | head -n 1

# Test GitHub (for Kubespray downloads)
curl -I https://github.com 2>/dev/null | head -n 1
```

Expected: HTTP 200, 301, 302, or 401 responses (401 is normal for unauthenticated registry access)

### 5. Check for Required Ports (Target Node)

Ensure these ports are available:
```bash
# Check if nginx port (8080) is free
sudo ss -tuln | grep ':8080'
# Should return nothing if port is free

# Check if registry port (35000) is free
sudo ss -tuln | grep ':35000'
# Should return nothing if port is free
```

### 6. Verify Python Installation

Check Python version:
```bash
python3 --version
# Should show Python 3.9 or later
```

### 7. Check SELinux Status (RHEL/AlmaLinux/Rocky Linux)

```bash
getenforce
# Can be Enforcing, Permissive, or Disabled
# If Enforcing, be aware of potential SELinux policies
```

### 8. Verify Git Availability (Optional, for custom branches)

```bash
git --version
```

## Download offline files (Preparation Node)

**Important**: You must execute this process on the same OS as your Kubernetes target nodes. OS and version must match exactly.

### Step 1: Configure Download Settings

Edit the configuration file to customize your environment:

```bash
vim config.sh
```

**Key Configuration Options** (in `target-scripts/config.sh`):

- `KUBESPRAY_VERSION`: Kubespray version to download (default: 2.29.0)
- `REGISTRY_PORT`: Local registry port (default: 35000)
- `docker`: Container runtime for preparation node (default: podman)

**Example Configuration:**
```bash
KUBESPRAY_VERSION=2.29.0
REGISTRY_PORT=35000
docker=podman
```

### Step 2: Choose Container Runtime (Optional)

By default, `podman` is automatically installed and used. To use `containerd` instead:

```bash
# Install containerd and nerdctl
./install-containerd.sh

# Edit config.sh and set:
# docker=/usr/local/bin/nerdctl
vim config.sh
```

**Verify container runtime:**
```bash
# For podman
podman version

# For nerdctl
nerdctl version
```

### Step 3: Download All Offline Files

Execute the main download script:

```bash
./download-all.sh
```

**Expected Duration**: 30-90 minutes depending on:
- Internet connection speed
- Number of container images
- Kubernetes version
- OS package count

**Monitor Progress:**
The script will display progress for each phase. Watch for:
- ✓ Successful completions
- Download progress percentages
- Any error messages

**Expected Output Directory Structure:**
```
./outputs/
├── files/              # Kubernetes binaries and files
├── rpms/ or debs/      # OS packages repository
├── registry/           # Container images
├── kubespray-*.tar.gz  # Kubespray source
├── config.sh           # Configuration file
└── *.sh                # Target node scripts
```

### Step 4: Verify Downloaded Content

Check that all files were downloaded successfully:

```bash
# Check output directory size
du -sh ./outputs/
# Expected: 15-40GB depending on configuration

# List main components
ls -lh ./outputs/

# Verify Kubespray tarball exists
ls -lh ./outputs/kubespray-*.tar.gz

# Check container images
ls -lh ./outputs/registry/ | head -n 10

# Verify OS packages (RHEL/Rocky/Alma)
ls -lh ./outputs/rpms/ 2>/dev/null || echo "Not RHEL-based"

# Verify OS packages (Ubuntu)
ls -lh ./outputs/debs/ 2>/dev/null || echo "Not Ubuntu"
```

### Download Phase Script Details

The `download-all.sh` script orchestrates these subscripts in order:

1. **prepare-pkgs.sh**
   - Installs required system packages (python, podman, etc.)
   - Duration: 2-5 minutes
   - Verification: `which podman` or `which nerdctl`

2. **prepare-py.sh**
   - Creates Python virtual environment
   - Installs required Python packages
   - Duration: 2-5 minutes
   - Verification: `ls -la .venv/`

3. **get-kubespray.sh**
   - Downloads and extracts Kubespray release
   - Skipped if KUBESPRAY_DIR already exists
   - Duration: 1-3 minutes
   - Verification: `ls -d kubespray-*/`

4. **pypi-mirror.sh**
   - Downloads PyPI mirror files for offline pip installs
   - Duration: 5-15 minutes
   - Verification: `ls outputs/files/pypi/`

5. **download-kubespray-files.sh**
   - Downloads Kubernetes binaries (kubeadm, kubectl, kubelet)
   - Downloads CNI plugins, crictl, helm, etc.
   - Duration: 5-10 minutes
   - Verification: `ls outputs/files/`

6. **download-images.sh**
   - Downloads all container images required by Kubespray
   - Largest and slowest phase
   - Duration: 20-60 minutes
   - Verification: `podman images` or `nerdctl images`

7. **download-additional-containers.sh**
   - Downloads custom container images from imagelists/*.txt
   - Duration: 1-5 minutes
   - Verification: Check custom images in registry

8. **create-repo.sh**
   - Downloads OS packages (RPM or DEB)
   - Creates local repository metadata
   - Duration: 10-30 minutes
   - Verification: `ls outputs/rpms/` or `ls outputs/debs/`

9. **copy-target-scripts.sh**
   - Copies target node scripts to outputs/
   - Duration: < 1 minute
   - Verification: `ls outputs/*.sh`

### Step 5: Prepare for Transfer

Package the outputs directory for transfer to target node:

```bash
# Optional: Create compressed archive for easier transfer
tar czf kubespray-offline-outputs.tar.gz outputs/

# Check archive size
ls -lh kubespray-offline-outputs.tar.gz
```

**Transfer Methods:**
- USB drive
- SCP/rsync over network
- Physical media
- Shared storage

## Target Node Setup

This section describes the setup process on your Kubernetes target node(s). The target node should be in an air-gapped/offline environment.

### Step 1: Transfer Files to Target Node

Copy the entire `outputs` directory from your preparation node to the target node.

**Option A: Using SCP (if network is available)**
```bash
# From preparation node
scp -r outputs/ user@target-node:/path/to/destination/

# Or using rsync
rsync -avz --progress outputs/ user@target-node:/path/to/destination/
```

**Option B: Using USB/Physical Media**
```bash
# On preparation node
cp -r outputs/ /media/usb-drive/

# On target node
cp -r /media/usb-drive/outputs/ /home/user/
```

**Option C: Extract from Archive**
```bash
# On target node
tar xzf kubespray-offline-outputs.tar.gz
```

**Verify Transfer:**
```bash
cd outputs/
ls -lh
# Should see: config.sh, various .sh scripts, files/, registry/, rpms/ or debs/
```

### Step 2: Setup Containerd

Install containerd and load initial container images (nginx and registry):

```bash
cd outputs/
./setup-container.sh
```

**What this does:**
- Installs containerd, runc, CNI plugins from local files
- Configures containerd systemd service
- Starts containerd
- Loads nginx and registry container images

**Expected Duration**: 2-5 minutes

**Verification:**
```bash
# Check containerd is running
sudo systemctl status containerd
# Expected: active (running)

# Verify containerd service
sudo ctr version

# Check loaded images
sudo ctr images ls | grep -E "nginx|registry"
# Expected: Should show nginx and registry images
```

**Troubleshooting:**
- If containerd fails to start, check logs: `sudo journalctl -u containerd -n 50`
- Ensure no other container runtime is conflicting
- Check SELinux: `sudo ausearch -m avc -ts recent`

### Step 3: Start Nginx Web Server

Start nginx container to serve OS packages, PyPI mirror, and Kubernetes binaries:

```bash
./start-nginx.sh
```

**What this does:**
- Starts nginx container on port 8080 (configurable in config.sh)
- Serves files/, rpms/debs/ directories via HTTP
- Provides local file server for offline installation

**Expected Duration**: < 1 minute

**Verification:**
```bash
# Check nginx container is running
sudo ctr task ls | grep nginx
# Expected: Running status

# Test nginx is serving files
curl -I http://localhost:8080/files/
# Expected: HTTP/1.1 200 OK

# Test repository access (RHEL-based)
curl -I http://localhost:8080/rpms/
# Or for Ubuntu
curl -I http://localhost:8080/debs/

# Get your node IP for later configuration
ip addr show | grep "inet " | grep -v 127.0.0.1
# Note this IP - you'll need it for offline.yml
```

**Troubleshooting:**
- If nginx doesn't respond, check container logs: `sudo ctr task exec --exec-id debug nginx sh -c "cat /var/log/nginx/error.log"`
- Verify port 8080 is not in use: `sudo ss -tuln | grep 8080`
- Check firewall: `sudo firewall-cmd --list-all` (if using firewalld)

### Step 4: Configure Offline Repositories

Configure the system to use local nginx server for package installation:

```bash
./setup-offline.sh
```

**What this does:**
- Disables external package repositories
- Configures yum/dnf to use local HTTP server (RHEL-based)
- Configures apt to use local HTTP server (Ubuntu)
- Sets up pip to use local PyPI mirror

**Expected Duration**: < 1 minute

**Verification:**
```bash
# For RHEL/AlmaLinux/Rocky Linux
yum repolist
# Expected: Should show local repository

# For Ubuntu
apt-cache policy
# Expected: Should show local repository

# Test package availability (RHEL-based)
yum list available | head -n 20

# Test package availability (Ubuntu)
apt-cache search python3 | head -n 20

# Check pip configuration
cat ~/.pip/pip.conf
# Expected: Should show local PyPI mirror URL
```

**Important Notes:**
- After this step, the node relies entirely on the local nginx server
- Ensure nginx remains running throughout the installation process

### Step 5: Install Python

Install Python3 and venv from the local repository:

```bash
./setup-py.sh
```

**What this does:**
- Installs Python 3.11 (or latest available version)
- Installs python3-venv and related packages
- Uses local repository configured in previous step

**Expected Duration**: 2-5 minutes

**Verification:**
```bash
# Check Python installation
python3 --version
# Expected: Python 3.11.x or later

# Verify Python location
which python3

# Test venv creation
python3 -m venv test-venv
source test-venv/bin/activate
python --version
deactivate
rm -rf test-venv
```

### Step 6: Start Docker Registry

Start a local Docker registry container to host Kubernetes images:

```bash
./start-registry.sh
```

**What this does:**
- Starts Docker registry v2 on port 35000 (configurable in config.sh)
- Provides local container registry for all Kubernetes images
- Configured as insecure registry for HTTP access

**Expected Duration**: < 1 minute

**Verification:**
```bash
# Check registry container is running
sudo ctr task ls | grep registry
# Expected: Running status

# Test registry API
curl -X GET http://localhost:35000/v2/_catalog
# Expected: {"repositories":[]} (empty initially)

# Verify registry port
sudo ss -tuln | grep 35000
# Expected: Should show LISTEN on port 35000
```

**Important**: Note your node's IP and registry port (default: 35000) - you'll need this for offline.yml configuration.

### Step 7: Load and Push Container Images

Load all container images to containerd and push them to the local registry:

```bash
./load-push-images.sh
```

**What this does:**
- Loads all container images from registry/ directory
- Tags images for local registry
- Pushes all images to local registry (localhost:35000)
- This is the longest step in target node setup

**Expected Duration**: 20-60 minutes (depends on number and size of images)

**Monitor Progress:**
```bash
# In another terminal, watch registry contents
watch -n 5 'curl -s http://localhost:35000/v2/_catalog | jq'

# Check containerd images
sudo ctr images ls | wc -l
# Number should increase over time
```

**Verification:**
```bash
# List all images in registry
curl -s http://localhost:35000/v2/_catalog | jq '.repositories[]' | head -n 20

# Count images in registry
curl -s http://localhost:35000/v2/_catalog | jq '.repositories | length'
# Expected: 50+ images depending on Kubernetes version

# Verify specific Kubernetes images
curl -s http://localhost:35000/v2/_catalog | jq '.repositories[]' | grep -E "kube-apiserver|kube-controller|kube-scheduler"

# Check image tags for a specific image
curl -s http://localhost:35000/v2/kube-apiserver/tags/list | jq
```

**Troubleshooting:**
- If push fails, check registry logs: `sudo ctr task logs registry`
- Verify network connectivity: `curl -v http://localhost:35000/v2/`
- Check disk space: `df -h`

### Step 8: Extract and Prepare Kubespray

Extract Kubespray source code and apply any patches:

```bash
./extract-kubespray.sh
```

**What this does:**
- Extracts kubespray-*.tar.gz
- Applies patches from patches/ directory (if any)
- Prepares Kubespray for deployment

**Expected Duration**: < 1 minute

**Verification:**
```bash
# Check extracted directory
ls -d kubespray-*/
# Expected: kubespray-2.29.0/ (or your version)

# Verify Kubespray contents
ls kubespray-*/
# Expected: inventory/, roles/, cluster.yml, requirements.txt, etc.

# Check Kubespray version
cat kubespray-*/roles/kubespray-defaults/defaults/main/main.yml | grep kube_version
```

### Configuration Summary

After completing these steps, you should have:

1. ✓ Containerd running and configured
2. ✓ Nginx serving files on port 8080
3. ✓ Local package repositories configured
4. ✓ Python 3.11+ installed
5. ✓ Docker registry running on port 35000
6. ✓ All container images loaded and pushed to registry
7. ✓ Kubespray extracted and ready

**Record these values for next phase:**
- **Node IP**: `ip -4 addr show | grep inet | grep -v 127.0.0.1`
- **Registry URL**: `<NODE_IP>:35000`
- **HTTP Server**: `http://<NODE_IP>:8080`

You can configure port numbers of nginx and private registry in `config.sh` before running the scripts.

## Deploy Kubernetes using Kubespray

### Step 1: Create Python Virtual Environment

Create and activate a Python virtual environment for Ansible:

```bash
# Create virtual environment with Python 3.11
python3.11 -m venv ~/.venv/3.11

# Activate the virtual environment
source ~/.venv/3.11/bin/activate

# Verify Python version
python --version
# Expected: Python 3.11.x
```

**Verification:**
```bash
# Check you're in the venv (prompt should show venv name)
which python
# Expected: /home/user/.venv/3.11/bin/python
```

**Important**: Always activate this venv before running Ansible commands.

### Step 2: Extract Kubespray (if not done already)

```bash
cd outputs/
./extract-kubespray.sh
cd kubespray-2.29.0  # Replace with your version
```

### Step 3: Install Ansible and Dependencies

Install Ansible and required Python packages from local PyPI mirror:

```bash
# Upgrade pip first
pip install -U pip

# Install Ansible and dependencies
pip install -r requirements.txt
```

**Expected Duration**: 3-5 minutes

**Verification:**
```bash
# Verify Ansible installation
ansible --version
# Expected: ansible [core 2.x.x]

# Check installed packages
pip list | grep -E "ansible|jinja2|netaddr"
```

### Step 4: Create Kubespray Inventory

If you don't have an inventory yet, create one:

```bash
# Copy sample inventory
cp -rfp inventory/sample inventory/mycluster

# Edit inventory file with your nodes
vim inventory/mycluster/hosts.yaml
```

**Example hosts.yaml structure:**
```yaml
all:
  hosts:
    node1:
      ansible_host: 192.168.1.10
      ip: 192.168.1.10
    node2:
      ansible_host: 192.168.1.11
      ip: 192.168.1.11
    node3:
      ansible_host: 192.168.1.12
      ip: 192.168.1.12
  children:
    kube_control_plane:
      hosts:
        node1:
    kube_node:
      hosts:
        node1:
        node2:
        node3:
    etcd:
      hosts:
        node1:
    k8s_cluster:
      children:
        kube_control_plane:
        kube_node:
```

**Test connectivity:**
```bash
ansible -i inventory/mycluster/hosts.yaml all -m ping
# Expected: SUCCESS for all nodes
```

### Step 5: Configure offline.yml

Copy and customize the offline configuration file:

```bash
# Create group_vars/all directory if it doesn't exist
mkdir -p inventory/mycluster/group_vars/all

# Copy offline.yml template
cp ../offline.yml inventory/mycluster/group_vars/all/

# Edit offline.yml
vim inventory/mycluster/group_vars/all/offline.yml
```

**Critical Configuration Changes:**

Replace `YOUR_HOST` with your node's IP address (from Step 8 of Target Node Setup):

```yaml
# Before (template):
http_server: "http://YOUR_HOST"
registry_host: "YOUR_HOST:35000"

# After (example with IP 192.168.1.10):
http_server: "http://192.168.1.10:8080"
registry_host: "192.168.1.10:35000"
```

**Important Notes:**

1. **Port Numbers**: Default is 8080 for nginx and 35000 for registry. If you changed these in `config.sh`, update them here.

2. **Registry Configuration**: The `containerd_registries_mirrors` configuration changed from Kubespray 2.23.0. Use the new format provided in offline.yml.

3. **runc_download_url**: Must include `runc_version` variable, which differs from Kubespray's official documentation.

**Verification:**
```bash
# Verify offline.yml syntax
cat inventory/mycluster/group_vars/all/offline.yml | grep -E "http_server|registry_host"
# Should show your actual IP, not YOUR_HOST

# Test HTTP server accessibility
curl -I $(grep http_server inventory/mycluster/group_vars/all/offline.yml | cut -d'"' -f2)/files/
# Expected: HTTP/1.1 200 OK

# Test registry accessibility
curl -I http://$(grep registry_host inventory/mycluster/group_vars/all/offline.yml | cut -d'"' -f2 | cut -d':' -f1):35000/v2/
# Expected: HTTP 200
```

### Step 6: Deploy Offline Repository Configuration

Deploy offline repository configuration to all cluster nodes:

```bash
# Copy offline-repo playbook to kubespray directory
cp -r ../playbook .

# Execute offline-repo playbook
ansible-playbook -i inventory/mycluster/hosts.yaml playbook/offline-repo.yml
```

**What this does:**
- Configures all cluster nodes to use local yum/deb repositories
- Sets up PyPI mirror on all nodes
- Ensures consistent offline configuration across cluster

**Expected Duration**: 2-5 minutes

**Verification:**
```bash
# Verify repo configuration on nodes
ansible -i inventory/mycluster/hosts.yaml all -m shell -a "yum repolist" --become
# Or for Ubuntu:
ansible -i inventory/mycluster/hosts.yaml all -m shell -a "apt-cache policy" --become

# Expected: All nodes should show local repository
```

### Step 7: Run Kubespray Deployment

Deploy Kubernetes cluster using Kubespray:

```bash
ansible-playbook -i inventory/mycluster/hosts.yaml --become --become-user=root cluster.yml
```

**Expected Duration**: 20-45 minutes (varies by cluster size)

**What happens during deployment:**
- Installs container runtime on all nodes
- Downloads and installs Kubernetes binaries (from local nginx)
- Pulls container images (from local registry)
- Configures etcd cluster
- Sets up Kubernetes control plane
- Joins worker nodes
- Installs network plugin (Calico/Cilium/etc.)
- Installs DNS addon (CoreDNS)

**Monitor Progress:**
The playbook will show detailed progress. Key phases to watch:
- `kubernetes/preinstall`: System preparation
- `etcd`: etcd cluster setup
- `kubernetes/control-plane`: Control plane installation
- `kubernetes/node`: Worker node configuration
- `network_plugin`: CNI installation

**Common Output During Success:**
```
PLAY RECAP *********************************************************************
node1                      : ok=XXX  changed=YYY  unreachable=0    failed=0
node2                      : ok=XXX  changed=YYY  unreachable=0    failed=0
node3                      : ok=XXX  changed=YYY  unreachable=0    failed=0
```

### Step 8: Verify Kubernetes Cluster

After deployment completes, verify your cluster:

```bash
# SSH to control plane node
ssh node1

# Check cluster status
sudo kubectl get nodes
# Expected: All nodes in Ready status

# Check system pods
sudo kubectl get pods -A
# Expected: All pods Running or Completed

# Check cluster info
sudo kubectl cluster-info

# Verify all components
sudo kubectl get componentstatuses
```

**For kubectl access from your workstation:**
```bash
# Copy kubeconfig from control plane
mkdir -p ~/.kube
scp node1:/etc/kubernetes/admin.conf ~/.kube/config

# Or copy from Ansible output
mkdir -p ~/.kube
cp inventory/mycluster/artifacts/admin.conf ~/.kube/config

# Test access
kubectl get nodes
kubectl get pods -A
```

### Step 9: Post-Deployment Checks

Verify all critical components:

```bash
# Check all namespaces
kubectl get ns

# Check node status with details
kubectl describe nodes | grep -E "Name:|Ready|KubeletReady"

# Verify container runtime
kubectl get nodes -o wide
# Check CONTAINER-RUNTIME column

# Check DNS resolution (create test pod)
kubectl run test-dns --image=busybox:1.28 --rm -it --restart=Never -- nslookup kubernetes.default
# Expected: Should resolve successfully

# Verify local registry is being used
kubectl describe pod -n kube-system kube-apiserver-* | grep Image:
# Should show your local registry (e.g., 192.168.1.10:35000)
```

**Troubleshooting Deployment Issues:**
- If a task fails, check the error message carefully
- Review logs on affected node: `journalctl -u kubelet -n 100`
- Verify registry access: `curl http://<REGISTRY_HOST>:35000/v2/_catalog`
- Check nginx is serving files: `curl http://<HTTP_SERVER>/files/`
- Ensure all nodes can reach the registry/nginx node

## Verification

### Quick Health Check

Run this comprehensive health check after deployment:

```bash
#!/bin/bash
echo "=== Kubernetes Cluster Health Check ==="

echo -e "\n1. Node Status:"
kubectl get nodes -o wide

echo -e "\n2. System Pods Status:"
kubectl get pods -n kube-system

echo -e "\n3. All Pods Status:"
kubectl get pods -A | grep -v Running | grep -v Completed

echo -e "\n4. Component Status:"
kubectl get --raw='/readyz?verbose'

echo -e "\n5. Cluster Info:"
kubectl cluster-info

echo -e "\n6. Check Critical Services:"
kubectl get svc -A | grep -E "kubernetes|kube-dns|coredns"

echo -e "\n7. Check PersistentVolumes (if any):"
kubectl get pv,pvc -A

echo -e "\n=== Health Check Complete ==="
```

### Service Verification

**Check Nginx Server:**
```bash
# On target node
sudo ctr task ls | grep nginx
curl -I http://localhost:8080/files/

# From other nodes in cluster
curl -I http://<NGINX_NODE_IP>:8080/files/
```

**Check Registry:**
```bash
# On target node
sudo ctr task ls | grep registry
curl http://localhost:35000/v2/_catalog | jq

# Count images
curl -s http://localhost:35000/v2/_catalog | jq '.repositories | length'

# Check specific image tags
curl http://localhost:35000/v2/kube-apiserver/tags/list | jq
```

**Check Containerd:**
```bash
# List all loaded images
sudo ctr images ls | wc -l

# Check containerd is running
sudo systemctl status containerd

# View containerd configuration
sudo cat /etc/containerd/config.toml | grep registry
```

### Network Verification

**Test Pod-to-Pod Communication:**
```bash
# Create test deployment
kubectl create deployment test-nginx --image=nginx:latest --replicas=3

# Wait for pods to be ready
kubectl wait --for=condition=Ready pod -l app=test-nginx --timeout=300s

# Get pod IPs
kubectl get pods -l app=test-nginx -o wide

# Test connectivity from one pod to another
POD1=$(kubectl get pods -l app=test-nginx -o jsonpath='{.items[0].metadata.name}')
POD2_IP=$(kubectl get pods -l app=test-nginx -o jsonpath='{.items[1].status.podIP}')
kubectl exec $POD1 -- curl -s http://$POD2_IP | head -n 5

# Cleanup
kubectl delete deployment test-nginx
```

**Test DNS:**
```bash
# Test internal DNS resolution
kubectl run test-dns --image=busybox:1.28 --rm -it --restart=Never -- nslookup kubernetes.default

# Test external DNS (if configured)
kubectl run test-dns-ext --image=busybox:1.28 --rm -it --restart=Never -- nslookup google.com
```

### Storage Verification

**Test Storage (if storage class is configured):**
```bash
# Create test PVC
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: test-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
EOF

# Check PVC status
kubectl get pvc test-pvc

# Create pod using PVC
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: test-storage-pod
spec:
  containers:
  - name: test
    image: busybox
    command: ['sh', '-c', 'echo "Storage test" > /data/test.txt && cat /data/test.txt && sleep 3600']
    volumeMounts:
    - name: storage
      mountPath: /data
  volumes:
  - name: storage
    persistentVolumeClaim:
      claimName: test-pvc
EOF

# Verify pod and storage
kubectl wait --for=condition=Ready pod/test-storage-pod --timeout=60s
kubectl logs test-storage-pod
# Expected: "Storage test"

# Cleanup
kubectl delete pod test-storage-pod
kubectl delete pvc test-pvc
```

## Troubleshooting

### Common Issues and Solutions

#### Issue 1: Download Phase - Podman/Container Runtime Errors

**Symptom:**
```
Error: cannot pull image: connection refused
```

**Solutions:**
```bash
# Check podman/nerdctl is running
podman version
# or
nerdctl version

# Restart podman
sudo systemctl restart podman

# Check network connectivity
curl -I https://registry-1.docker.io/v2/

# Clear podman cache and retry
podman system prune -a -f
```

#### Issue 2: Insufficient Disk Space

**Symptom:**
```
No space left on device
```

**Solutions:**
```bash
# Check disk usage
df -h

# Clean up container images on preparation node
podman system prune -a -f

# Remove old downloads
rm -rf outputs/old-backups/

# Check for large temp files
du -sh /tmp/* | sort -h | tail -n 10
```

#### Issue 3: Target Node - Nginx Not Starting

**Symptom:**
```
Failed to start nginx container
```

**Solutions:**
```bash
# Check if port 8080 is already in use
sudo ss -tuln | grep :8080

# Kill process using port 8080
sudo lsof -ti:8080 | xargs kill -9

# Check containerd status
sudo systemctl status containerd

# View containerd logs
sudo journalctl -u containerd -n 100

# Check if nginx image is loaded
sudo ctr images ls | grep nginx

# Try starting nginx manually
cd outputs/
./start-nginx.sh
```

#### Issue 4: Registry Push Failures

**Symptom:**
```
failed to push: connection refused
```

**Solutions:**
```bash
# Verify registry is running
sudo ctr task ls | grep registry
curl http://localhost:35000/v2/

# Restart registry
sudo ctr task kill registry
./start-registry.sh

# Check registry logs
sudo ctr task logs registry | tail -n 50

# Verify disk space
df -h

# Test registry manually
curl -X GET http://localhost:35000/v2/_catalog
```

#### Issue 5: Ansible Connection Failures

**Symptom:**
```
Failed to connect to the host via ssh
```

**Solutions:**
```bash
# Test SSH connectivity
ansible -i inventory/mycluster/hosts.yaml all -m ping

# Check SSH keys
ssh-copy-id user@node1

# Try with password authentication
ansible -i inventory/mycluster/hosts.yaml all -m ping --ask-pass

# Verify inventory file syntax
ansible-inventory -i inventory/mycluster/hosts.yaml --list

# Test direct SSH
ssh user@node1 "echo 'SSH works'"
```

#### Issue 6: Kubespray Fails to Pull Images

**Symptom:**
```
Failed to pull image from registry
```

**Solutions:**
```bash
# Verify offline.yml configuration
cat inventory/mycluster/group_vars/all/offline.yml | grep registry_host

# Test registry from target node
curl http://<REGISTRY_HOST>:35000/v2/_catalog

# Check containerd mirrors configuration
sudo cat /etc/containerd/config.toml | grep -A 10 registry

# Manually test image pull
sudo ctr image pull <REGISTRY_HOST>:35000/kube-apiserver:v1.30.0 --plain-http

# Check firewall
sudo firewall-cmd --list-all
sudo firewall-cmd --add-port=35000/tcp --permanent
sudo firewall-cmd --reload
```

#### Issue 7: Nodes Not Ready

**Symptom:**
```
node1   NotReady   control-plane   5m
```

**Solutions:**
```bash
# Check node details
kubectl describe node node1

# Check kubelet logs
ssh node1 "sudo journalctl -u kubelet -n 100"

# Verify CNI plugin
ssh node1 "ls -la /opt/cni/bin/"

# Check CNI pods
kubectl get pods -n kube-system | grep -E "calico|cilium|flannel"

# Restart kubelet
ssh node1 "sudo systemctl restart kubelet"

# Check containerd
ssh node1 "sudo systemctl status containerd"
```

#### Issue 8: CoreDNS Pods Not Running

**Symptom:**
```
coredns-xxx   0/1   ImagePullBackOff
```

**Solutions:**
```bash
# Check DNS pod status
kubectl describe pod -n kube-system coredns-xxx

# Verify DNS image in registry
curl http://<REGISTRY_HOST>:35000/v2/coredns/tags/list

# Check containerd can pull from registry
sudo ctr image pull <REGISTRY_HOST>:35000/coredns:v1.11.1 --plain-http

# Delete and recreate DNS deployment
kubectl delete pod -n kube-system -l k8s-app=kube-dns
```

#### Issue 9: Python Package Installation Fails

**Symptom:**
```
ERROR: Could not find a version that satisfies the requirement
```

**Solutions:**
```bash
# Verify PyPI mirror is accessible
curl http://<HTTP_SERVER>:8080/files/pypi/

# Check pip configuration
cat ~/.pip/pip.conf

# Test pip with local mirror
pip install --index-url http://<HTTP_SERVER>:8080/files/pypi/simple/ --trusted-host <HTTP_SERVER> ansible

# Manually download and install
cd outputs/files/pypi/
pip install ansible*.whl
```

#### Issue 10: SELinux Blocking Operations (RHEL/Rocky/Alma)

**Symptom:**
```
Permission denied (SELinux)
```

**Solutions:**
```bash
# Check SELinux status
getenforce

# View SELinux denials
sudo ausearch -m avc -ts recent

# Temporarily set to permissive (not recommended for production)
sudo setenforce 0

# Or disable SELinux (requires reboot)
sudo sed -i 's/^SELINUX=enforcing/SELINUX=permissive/' /etc/selinux/config

# Generate and apply SELinux policy (recommended)
sudo ausearch -m avc -ts recent | audit2allow -M mypolicy
sudo semodule -i mypolicy.pp
```

### Log Locations

**Preparation Node:**
- Download logs: `./outputs/*.log` (if logging enabled)
- Podman logs: `journalctl -u podman`

**Target Node:**
- Containerd: `/var/log/containerd/` or `journalctl -u containerd`
- Kubelet: `/var/log/kubelet.log` or `journalctl -u kubelet`
- Nginx container: `sudo ctr task logs nginx`
- Registry container: `sudo ctr task logs registry`

**Kubernetes:**
- System pods: `kubectl logs -n kube-system <pod-name>`
- Events: `kubectl get events -A --sort-by='.lastTimestamp'`
- Audit logs: `/var/log/kubernetes/audit.log` (if enabled)

### Getting Help

If you encounter issues not covered here:

1. **Check Logs**: Always start by checking relevant logs
2. **Verify Network**: Ensure nodes can communicate
3. **Check Resources**: Verify disk space, memory, CPU
4. **Review Configuration**: Double-check offline.yml and config.sh
5. **Test Components**: Verify nginx and registry are accessible
6. **Consult Kubespray**: Check [Kubespray documentation](https://kubespray.io) for general Kubernetes issues
7. **GitHub Issues**: Search or create issues at [kubespray-offline issues](https://github.com/kubernetes-sigs/kubespray/issues)

### Useful Debug Commands

```bash
# System resources
free -h
df -h
top

# Network connectivity
ping <node-ip>
nc -zv <node-ip> 35000
curl -v http://<node-ip>:8080/files/

# Container status
sudo ctr namespaces ls
sudo ctr containers ls
sudo ctr tasks ls
sudo ctr images ls

# Kubernetes debugging
kubectl get events -A --sort-by='.lastTimestamp' | tail -n 20
kubectl describe node <node-name>
kubectl logs -n kube-system <pod-name> --previous
kubectl get pods -A -o wide
kubectl top nodes
kubectl top pods -A
```
