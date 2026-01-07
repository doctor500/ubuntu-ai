# Kubeadm Installation Bundle Context

## Overview
Install kubeadm, kubelet, and kubectl to set up a single-node Kubernetes cluster on Ubuntu 24.04.

## Goal
Provision the VM with all Kubernetes components needed to run a single-node cluster for local development, testing, and learning. The node acts as both control plane and worker, allowing pods to be scheduled on it.

## Triggers
When should an AI agent invoke this procedure?
- User requests Kubernetes installation
- Setting up local development environment with K8s
- User wants container orchestration beyond containerd
- Following autoinstall.yaml that includes kubeadm packages

## Prerequisites
**Common:** See common_patterns.md#standard-prerequisites

**Specific:**
- containerd.io installed (we have it ✅)
- Passwordless sudo configured (recommended)
- Internet connectivity
- Minimum: 2 vCPU, 4GB RAM, 20GB disk

## Single-Node vs Multi-Node

| Aspect | Single-Node (This Bundle) | Multi-Node (Future) |
|--------|---------------------------|---------------------|
| **Nodes** | 1 VM = control plane + worker | Separate VMs |
| **Use Case** | Dev/test, learning | Production, HA |
| **Setup** | `kubeadm init` + untaint | `kubeadm init` + `join` |
| **Complexity** | Low | Higher |
| **Time** | ~5 minutes | ~15-30 minutes |

**Key Difference:** Single-node removes control-plane taint so pods can run on it.

## Components Installed

### Core Kubernetes
| Package | Purpose |
|---------|---------|
| **kubelet** | Node agent |
| **kubeadm** | Bootstrap tool |
| **kubectl** | CLI |

### Container Runtime
| Package | Purpose |
|---------|---------|
| **containerd.io** | Container runtime (already installed) |
| **nerdctl** | Docker-compatible CLI for containerd |

### Network Support
| Package | Purpose |
|---------|---------|
| **socat** | kubectl port-forward |
| **conntrack** | kube-proxy |

## Logic
Installation workflow:

### Phase 1: System Configuration
1. Load kernel modules (overlay, br_netfilter)
2. Configure sysctl (IP forwarding)
3. Disable swap
4. Configure containerd (SystemdCgroup)

### Phase 2: Install Packages
1. Add Kubernetes apt repository
2. Install kubelet, kubeadm, kubectl
3. Install socat, conntrack
4. Hold packages (prevent auto-upgrade)

### Phase 3: Initialize Cluster
1. Run kubeadm init
2. Configure kubectl for user
3. Remove control-plane taint
4. Install Flannel CNI
5. Verify with kubectl get nodes

## Related Files
- `context/autoinstall.yaml` - Packages and late-commands
- `installation_bundles/kubeadm/procedure.md` - Step-by-step commands
- `procedures/passwordless_sudo/` - Recommended prerequisite

## CNI Options
| Plugin | Complexity | Best For |
|--------|------------|----------|
| **Flannel** ⭐ | Simple | Single-node, learning |
| Calico | Medium | Production |
| Cilium | Complex | Advanced |

**Default:** Flannel

## AI Agent Notes
**Safety:** ASK | Significant system changes

**User Interaction:**
- Confirm Kubernetes installation
- Explain single-node mode
- Note post-install steps (kubeadm init)

**Common Issues:** See common_patterns.md#network-timeout, #permission-denied

**Procedure-Specific:**
- Swap not disabled → kubeadm init fails
- containerd not configured → Pods fail to start
- No CNI → Nodes stay NotReady
- kubelet not starting → Check journalctl -xeu kubelet

**Post-Install Required:**
```bash
# Run after VM provisioning:
k8s-init-single-node.sh
# or manual kubeadm init steps
```

**Version:** Kubernetes v1.31 (stable)
