# Kubeadm Installation Bundle Context

## Overview
Single-node Kubernetes cluster using kubeadm, kubelet, kubectl, and nerdctl.

## Goal
Provision a VM with Kubernetes for local development/testing. Node acts as both control plane and worker.

## Triggers
- User requests Kubernetes installation
- Setting up local K8s environment
- Following autoinstall.yaml with kubeadm packages

## Prerequisites
See common_patterns.md#standard-prerequisites

**Specific:**
- containerd.io installed ✅
- Passwordless sudo configured (recommended)
- Min: 2 vCPU, 4GB RAM, 20GB disk

## Single-Node vs Multi-Node

| Aspect | Single-Node | Multi-Node |
|--------|-------------|------------|
| Nodes | 1 VM (all-in-one) | Separate VMs |
| Setup | init + untaint | init + join |
| Time | ~5 min | ~15-30 min |

## Components

| Package | Purpose |
|---------|---------|
| kubelet | Node agent |
| kubeadm | Bootstrap tool |
| kubectl | CLI |
| containerd.io | Container runtime |
| nerdctl | Docker-compatible CLI |
| socat, conntrack | Network support |

## Logic
1. **System config:** Modules, sysctl, disable swap, configure containerd
2. **Install packages:** Add K8s repo, install kubelet/kubeadm/kubectl, hold versions
3. **Install nerdctl:** Download from GitHub releases
4. **Initialize cluster:** kubeadm init, configure kubectl, untaint, install Flannel

## Related Files
- `autoinstall.yaml` - Packages and late-commands
- `kubeadm/procedure.md` - Step-by-step commands

## AI Agent Notes

**Safety:** ASK | Significant system changes

**Interaction:** Confirm K8s install, explain single-node mode, note post-install steps

**Issues:** See common_patterns.md#network-timeout, #command-not-found

**Specific:**
- Swap not disabled → kubeadm init fails
- No CNI → Node stays NotReady
- kubelet issues → `journalctl -xeu kubelet`
- Post-install required: Run `k8s-init-single-node.sh`

**Version:** Kubernetes v1.31, nerdctl v2.2.1
