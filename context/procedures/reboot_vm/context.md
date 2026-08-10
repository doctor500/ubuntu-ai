# Reboot VM Procedure Context

## Overview
Gracefully reboot the single-node Kubernetes VM without corrupting the cluster.

## Goal
Reboot safely: cordon -> reboot -> verify -> uncordon. Zero workload corruption, full post-reboot verification.

## Triggers
- Kernel/systemd/glibc update applied (reboot required)
- Scheduled maintenance
- VM hangs or needs hardware reset
- User requests a reboot

## Prerequisites
See common_patterns.md#standard-prerequisites

**Specific:** VM accessible via SSH, kubectl works on VM (admin kubeconfig), ArgoCD CLI available

## Logic
1. **Pre-check:** node Ready, no stuck pods, all ArgoCD apps Synced/Healthy
2. **Cordon:** stop new scheduling (`kubectl cordon`)
3. **Reboot:** `sudo reboot`, poll until SSH responds (~70s typical)
4. **Verify (all gates C1-C6):** kernel, node Ready + NOT cordoned, all pods Running, in-cluster VIP reachable, kube-proxy at current IP, no stale iptables, ArgoCD healthy
5. **Uncordon:** restore scheduling (CRITICAL — frequently forgotten)
6. **Final sweep:** no stuck pods, clean up test pods

## Related Files
- `user_data.json` - VM connection details
- `vm_update_log.md` - Package update log (kernel version history)
- `change_log.md` - Project changelog (record reboot in Applied entries)

## AI Agent Notes

**Safety:** ASK | Modifies system state (node scheduling + reboot)

**Interaction:**
| Step | Action |
|------|--------|
| Pre-checks | Show cluster health summary |
| Before reboot | Ask: "Reboot VM now?" |
| After verification | Report all gates + uncordon confirmation |

**Issues:** See common_patterns.md#network-timeout

**Specific:**
- Single-node cluster = NO HA: reboot takes down control plane + all workloads together. Safe if ordered correctly.
- Cordon is a PAIR operation: whoever cordsons MUST uncordon after verification.
- `Ready,SchedulingDisabled` after reboot is a FAILURE state, not transitional.
- Slow workloads (n8n) show 0/1 for 90-120s post-reboot (readiness probe delay) — wait, do NOT restart.
- Kubernetes packages remain held at v1.31.14 — reboot does not change versions.

## Source Lesson
2026-08-11: node left cordoned after reboot -> nettest pod stuck Pending until uncordoned (caught by independent verifier). See workspace KB: @knowledge:graceful-reboot-of-single-node-kubernetes-vm
