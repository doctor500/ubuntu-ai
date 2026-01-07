# Kubeadm Installation Procedure

## Pre-Execution: Verify Procedure is Current

**Official Documentation:**
- Kubernetes: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/
- nerdctl: https://github.com/containerd/nerdctl/releases

**Last Verified:** 2026-01-07

**Versions Used:**
- Kubernetes: v1.31
- nerdctl: v2.2.1

**Quick Verification:**
```bash
# Check if Kubernetes repo is accessible
curl -I https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key 2>&1 | head -1
# Expected: HTTP/2 200

# Check latest nerdctl version
curl -s https://api.github.com/repos/containerd/nerdctl/releases/latest | grep tag_name
# Compare with v2.2.1 above
```

**If outdated:** Update versions in this procedure and autoinstall.yaml.

---

## Phase 1: System Configuration

### 1.1 Load Kernel Modules

```bash
# Load modules
sudo modprobe overlay
sudo modprobe br_netfilter

# Configure to load on boot
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
```

### 1.2 Configure Kernel Parameters

```bash
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

sudo sysctl --system
```

### 1.3 Disable Swap

```bash
sudo swapoff -a
sudo sed -i '/swap/d' /etc/fstab
```

### 1.4 Configure Containerd

```bash
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl restart containerd
```

---

## Phase 2: Install Kubernetes Packages

### 2.1 Add Repository

```bash
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
```

### 2.2 Install Packages

```bash
sudo apt-get install -y kubelet kubeadm kubectl socat conntrack
sudo apt-mark hold kubelet kubeadm kubectl
sudo systemctl enable kubelet
```

### 2.3 Install nerdctl (Docker-compatible CLI)

```bash
NERDCTL_VERSION="2.2.1"
cd /tmp
curl -sSL https://github.com/containerd/nerdctl/releases/download/v${NERDCTL_VERSION}/nerdctl-${NERDCTL_VERSION}-linux-amd64.tar.gz -o nerdctl.tar.gz
sudo tar -xzf nerdctl.tar.gz -C /usr/local/bin nerdctl
rm nerdctl.tar.gz
nerdctl --version
```

---

## Phase 3: Initialize Cluster

### 3.1 Initialize Control Plane

```bash
sudo kubeadm init --pod-network-cidr=10.244.0.0/16
```

### 3.2 Configure kubectl

```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

### 3.3 Enable Single-Node Mode

```bash
# Remove taint to allow pods on control plane
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
```

### 3.4 Install Flannel CNI

```bash
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
```

### 3.5 Verify

```bash
kubectl get nodes
# Expected: Ready status

kubectl get pods -n kube-system
# All pods should be Running
```

---

## Convenience Script

After installation, this script will be available:

```bash
#!/bin/bash
# /usr/local/bin/k8s-init-single-node.sh

set -e

echo "=== Initializing Single-Node Kubernetes ==="

if [ -f /etc/kubernetes/admin.conf ]; then
    echo "Already initialized. To reset: sudo kubeadm reset"
    exit 1
fi

sudo kubeadm init --pod-network-cidr=10.244.0.0/16

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl taint nodes --all node-role.kubernetes.io/control-plane- || true
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

echo "=== Kubernetes Ready! ==="
echo "Verify: kubectl get nodes"
```

---

## Troubleshooting

### kubelet not starting
```bash
sudo journalctl -xeu kubelet
# Check for swap or containerd issues
```

### Node not Ready
```bash
kubectl get pods -n kube-system
# Check if flannel pods are running
```

### kubeadm init fails
```bash
sudo kubeadm reset
sudo rm -rf /etc/cni/net.d
# Try init again
```

---

## Autoinstall.yaml Changes

### Packages
```yaml
packages:
  - kubelet
  - kubeadm
  - kubectl
  - socat
  - conntrack
```

### Late-Commands
See procedure for system configuration commands to add.
