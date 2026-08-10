# Reboot VM Procedure

## Quick Reference

```bash
# Pre-checks
ssh {{USER}}@{{IP}} 'kubectl get nodes -o wide && kubectl get pods -A | grep -v Running | grep -v Completed'

# Cordon + reboot
ssh {{USER}}@{{IP}} 'kubectl cordon {{NODE}}'
ssh {{USER}}@{{IP}} 'sudo reboot'   # SSH disconnect expected

# Wait for VM (70s typical)
for i in $(seq 1 60); do ssh -o ConnectTimeout=5 -o BatchMode=yes {{USER}}@{{IP}} 'echo ONLINE' 2>/dev/null && break; sleep 5; done

# Verify + UNCORDON (do not skip!)
ssh {{USER}}@{{IP}} 'uname -r && kubectl get nodes -o wide'
ssh {{USER}}@{{IP}} 'kubectl uncordon {{NODE}}'
```

---

## Phase 1: Pre-Checks (before reboot)

```bash
ssh {{USER}}@{{IP}} 'kubectl get nodes -o wide'          # node Ready
ssh {{USER}}@{{IP}} 'kubectl get pods -A | grep -v Running | grep -v Completed'  # must be empty
ssh {{USER}}@{{IP}} 'argocd app list'                    # all 7 apps Synced/Healthy
```

**Only proceed if everything is healthy.**

---

## Phase 2: Cordon + Reboot

```bash
# Stop new scheduling
ssh {{USER}}@{{IP}} 'kubectl cordon {{NODE}}'
# Confirm: kubectl get nodes -> Ready,SchedulingDisabled (expected at this point)

# Reboot (SSH will disconnect — that is normal)
ssh {{USER}}@{{IP}} 'sudo reboot'

# Poll until VM returns (typical 70s)
for i in $(seq 1 60); do
  ssh -o ConnectTimeout=5 -o BatchMode=yes {{USER}}@{{IP}} 'echo ONLINE' 2>/dev/null && break
  sleep 5
done
```

---

## Phase 3: Post-Reboot Verification (ALL gates)

```bash
# C1: kernel + node state
ssh {{USER}}@{{IP}} 'uname -r && kubectl get nodes -o wide'
#   PASS: new kernel active, node Ready

# C2: all pods running
ssh {{USER}}@{{IP}} 'kubectl get pods -A | grep -v Running | grep -v Completed'
#   PASS: empty output (allow 90-120s for slow workloads like n8n)

# C3: in-cluster VIP (any HTTP response, even 403, = connected)
ssh {{USER}}@{{IP}} 'kubectl run nettest --rm -i --image=curlimages/curl --restart=Never -- curl -sk --connect-timeout 5 https://10.96.0.1'

# C4: kube-proxy points at current IP
ssh {{USER}}@{{IP}} 'kubectl -n kube-system get cm kube-proxy -o yaml | grep "server:"'

# C5: no stale iptables (must return NOTHING)
ssh {{USER}}@{{IP}} 'sudo iptables-save | grep <old-IP>'

# C6: ArgoCD apps healthy
ssh {{USER}}@{{IP}} 'argocd app list'
```

---

## Phase 4: UNCORDON (critical — frequently forgotten)

```bash
ssh {{USER}}@{{IP}} 'kubectl uncordon {{NODE}}'
# Verify unschedulable=false:
ssh {{USER}}@{{IP}} 'kubectl get node {{NODE}} -o jsonpath="{.spec.unschedulable}"'
#   PASS: prints false
```

---

## Phase 5: Final Sweep

```bash
ssh {{USER}}@{{IP}} 'kubectl get pods -A | grep -vE "Running|Completed" | grep -v "^NAMESPACE"'
# must be empty

# Clean up leftover test pods if any
ssh {{USER}}@{{IP}} 'kubectl delete pod nettest --force --grace-period=0'
```

---

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| Pods stuck Pending after reboot | Node still cordoned | `kubectl uncordon {{NODE}}` (Phase 4) |
| n8n / slow workloads 0/1 Running | Exit 255 = killed by reboot; readiness probe 60s+ | Wait 90-120s, re-check; do NOT restart pods |
| `kubectl run nettest` hangs | Test pod unschedulable (cordoned node) | Uncordon first, then re-run |
| Node Ready but pods 'Unknown' | Transient post-reboot state | Wait 30s, re-check |
| VM does not return | Hardware/power issue | Check out-of-band console (iLO/IPMI/VirtualBox UI) |

---

## Post-Reboot Logging

Add entry to `context/change_log.md` (Applied section):

```markdown
### Applied (VM Reboot - YYYY-MM-DD)
- Reboot to kernel X.Y.Z (from A.B.C); node cordoned, graceful reboot
- Post-reboot verification: all ArgoCD apps Healthy, in-cluster VIP OK, kube-proxy at {{IP}}
```
