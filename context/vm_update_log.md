# VM Package Update Log

This file tracks package and bundle updates applied to the target VM.
It is gitignored — only package-level details go here. Structural project
changes go in `change_log.md`.

---

## 2026-08-11

### System Update — 111 packages
- **APT Packages Updated** (111 packages):
  - `containerd.io` 2.2.2 → 2.3.3
  - `packer` 1.15.0 → 1.16.0
  - `systemd` + related (14 packages) 255.4-1ubuntu8.16 → 8.17
  - `gdm3` + GNOME shell/mutter/GTK4 (10 packages) — point-release bumps
  - `apparmor` (2 packages) 4.0.1really4.0.1-0ubuntu0.24.04.5 → 0ubuntu0.24.04.7
  - `qemu-*` (7 packages) 1:8.2.2+ds-0ubuntu1.16 → 0ubuntu1.18
  - `network-manager` + netplan (6 packages) — point-release bumps
  - `xserver-xorg-*` (4 packages) 2:21.1.12-1ubuntu1.5 → 1ubuntu1.6
  - `linux-firmware` 20240318...0ubuntu2.26 → 0ubuntu2.27
  - `sssd` (13 packages) 2.9.4-1.1ubuntu6.5 → 1.1ubuntu6.6
  - `binutils` (5 packages) 2.42-4ubuntu2.8 → 4ubuntu2.10
  - `plymouth` (4 packages) 24.004.60-1ubuntu7.1 → 1ubuntu7.2
  - +48 other library/tool point-release bumps

- **Homebrew**: `k9s` 0.50.18 → 0.51.0 (already applied prior to this run)

- **Cleaned Up**: `libfwupd2` (507 KB freed)

---

## 2026-08-12

### System Update — 5 packages

- **APT Packages Updated** (5 packages):
  - `cri-tools` 1.31.1-1.1 → 1.35.0-1.1 (K8s CRI runtime — aligned with kubelet 1.35.7)
  - `kubernetes-cni` 1.5.1-1.1 → 1.8.0-1.1 (CNI plugin binaries — bridge/loopback/portmap)
  - `libyelp0` 42.2-1ubuntu0.24.04.1 → 42.2-1ubuntu0.24.04.2 (security)
  - `linux-firmware` 20240318.git3b128b60-0ubuntu2.27 → 0ubuntu2.29
  - `yelp` 42.2-1ubuntu0.24.04.1 → 42.2-1ubuntu0.24.04.2 (security)

- **Homebrew**: No outdated packages (Homebrew 6.0.17 current)

- **Holds Applied**: `kubelet`, `kubeadm`, `kubectl` (were unheld — restored per procedure)

- **Cluster Health Gate**: ✅ Passed — node Ready, 0 non-compliant pods, ArgoCD 7/7 Healthy, flannel Running

- **Cleaned Up**: None (autoremove erroneously removed cri-tools; immediately reinstalled)

### Notes
- cri-tools removed by autoremove (auto-installed flag); reinstalled and marked manual
- No reboot required after update
- K8s core (kubelet/kubeadm/kubectl) at v1.35.7 — held and unchanged

---

## 2026-09-02

### System Update — 26 packages + containerd + K8s trio + reboot

- **Part A — APT Packages Updated** (25 routine packages):
  - `snapd` 2.76 → 2.76.3
  - `procps` / `libproc2-0` 4.0.4-4ubuntu3.2 → 3.3
  - `python3.12` + libs (5 packages) 3.12.3-1ubuntu0.15 → 0.16
  - `krb5` family (7 packages) 1.20.1-6ubuntu2.7 → 2.8 (security)
  - `ncurses` family (5 packages) 6.4+20240113-1ubuntu2.1 → 2.2 (security)
  - `libgcrypt20` 1.10.3-2ubuntu0.1 → 0.2 (security)
  - `console-setup` + `keyboard-configuration` (3 packages)
  - `power-profiles-daemon` 0.21-1ubuntu1 → 1ubuntu2
  - `python3-pil` 10.2.0-1ubuntu1.2 → 1.3

- **Part B — containerd + reboot**:
  - `containerd.io` 2.3.3 → **2.3.4** (runtime upgrade; node cordoned + drained first)
  - Reboot to kernel **7.0.0-30** (cleared linux-firmware restart-required flag)

- **Part C — K8s trio** (executed by k8s-selfhosted):
  - `kubeadm` / `kubelet` / `kubectl` 1.35.7 → **1.35.8**

- **Homebrew**: No outdated packages

- **Holds**: `kubelet`, `kubeadm`, `kubectl` re-held at **v1.35.8**

- **Cluster Health Gate**: ✅ Passed — node Ready v1.35.8, 0 non-compliant pods, ArgoCD 7/7 Synced+Healthy, flannel Running, containerd v2.3.4

### Notes
- **power-profiles-daemon flag**: postinst hung on `systemctl restart` (desktop power daemon, non-K8s). Killed stuck systemctl to unblock dpkg. Service now `inactive` — fails to start (known 0.21 issue). Cosmetic, no cluster impact.
- containerd.io temporarily held during Part A to isolate routine batch; unheld + upgraded in Part B.
- K8s trio upgraded to 1.35.8 by k8s-selfhosted (parallel window); ubuntu-desktop re-applied holds + uncordoned after.

---

## 2026-09-11

### System Update — containerd 2.3.5 + ~29 routine packages + reboot

- **Part A — containerd.io (K8s runtime, node cordoned first)**:
  - `containerd.io` 2.3.4-2 → **2.3.5-1** (upgrade isolated by temporary hold of routine batch)

- **Part B — Routine/security APT packages** (~29 packages):
  - `libc6` family (6 packages: libc6, libc-bin, libc-dev-bin, libc-devtools, libc6-dbg, libc6-dev) 2.39-0ubuntu8.8 → 8.9 (security)
  - `python3.12` + `libpython3.12` (7 packages) 3.12.3-1ubuntu0.16 → 0.17 (security)
  - `wireless-regdb` 2026.02.04 → 2026.05.30 (security)
  - `locales` 2.39-0ubuntu8.8 → 8.9
  - `linux-firmware` 0ubuntu2.29 → 0ubuntu3.1 + split sub-packages (linux-firmware-* ~20 new)
  - `base-files` 13ubuntu10.4 → 13ubuntu10.5
  - `language-pack-en` (+-base, -gnome-en, -gnome-en-base) 20260127 → 20260905
  - `python-apt-common` / `python3-apt` 2.7.7ubuntu5.2 → 5.3
  - `python3-distupgrade` 1:24.04.28 → 24.04.29
  - `ubuntu-release-upgrader-core` / `-gtk` 1:24.04.28 → 24.04.29
  - `gnome-control-center` (+-data, +-faces) 1:46.7-0ubuntu0.24.04.5 → .6

- **Part C — Reboot**:
  - Reboot to kernel **7.0.0-31** (from 7.0.0-30). Kernel HWE 7.0.0-31 had been installed externally ~2026-09-03 but node was up 9 days un-rebooted; this reboot activated it.

- **Homebrew**: No outdated packages

- **Holds**: `kubelet`, `kubeadm`, `kubectl` held at **v1.35.8** (unchanged); containerd.io left unheld after upgrade (matches known-good)

- **Cluster Health Gate**: ✅ Passed — node Ready v1.35.8, kernel 7.0.0-31, containerd v2.3.5, all pods Running/Completed, ArgoCD apps Synced (n8n-1/n8n-2 Healthy after ~100s), kube-proxy at 10.253.11.2:6443, node uncordoned

### Notes
- **Phased updates left deferred** (Ubuntu phasing — will phase in automatically, not applied): `dnsmasq-base` 2.90→2.91, `power-profiles-daemon` 0.21-1ubuntu2→1ubuntu3.
- containerd.io temporarily held to isolate routine batch; unheld + upgraded in Part A, then left unheld.
- argocd CLI session token expired post-reboot; app health verified via `kubectl get applications -n argocd` instead.

---

## 2026-09-12

### System Update — 2 phased packages (completes 09-11 backlog)

- `dnsmasq-base` 2.90-2ubuntu0.4 → 2.91-0ubuntu0.24.04.1
- `power-profiles-daemon` 0.21-1ubuntu2 → 0.21-1ubuntu3

- **Holds**: `kubelet`, `kubeadm`, `kubectl` v1.35.8 (unchanged)
- **Reboot**: not required
- **Cluster impact**: none (both non-K8s desktop packages)

### Notes
- Applied with `-o APT::Get::Always-Include-Phased-Updates=true` (forced past Ubuntu phasing).
- **power-profiles-daemon fixed**: 0.21-1ubuntu3 postinst ran clean (no hang this time); service now `active` + `enabled` — resolves the 0.21-1ubuntu1/1ubuntu2 `inactive` failure noted in prior entries.

---

## 2026-09-16

### System Update — 16 packages (routine/security)

- **krb5 Kerberos security (5)** → 1.20.1-6ubuntu2.10
  - `krb5-locales`, `libgssapi-krb5-2`, `libk5crypto3`, `libkrb5-3`, `libkrb5support0`
- **polkit security (6)** → 124-2ubuntu1.24.04.4
  - `gir1.2-polkit-1.0`, `libpolkit-agent-1-0`, `libpolkit-gobject-1-0`, `pkexec`, `policykit-1`, `polkitd`
- **netplan (4)** → 1.1.2-8ubuntu1~24.04.3
  - `libnetplan1`, `netplan-generator`, `netplan.io`, `python3-netplan`
- **msr-tools (1)** → 1.3-5ubuntu0.1

- **Executed by**: deepseek-minion (plan + verify: ubuntu-desktop)

- **Holds**: `kubelet`, `kubeadm`, `kubectl` v1.35.8 (unchanged)
- **Reboot**: not required
- **Cluster impact**: none (no K8s runtime, no containerd)

### Cluster Health Gate
- ✅ Node Ready v1.35.8, 0 non-compliant pods, ArgoCD 7/7 Synced+Healthy, flannel Running

### Notes
- **Phasing (2nd occurrence)**: first pass upgraded 10/16; apt deferred 6 (`krb5` ×5 + `msr-tools`) for phased rollout. Applied the remaining 6 with `-o APT::Get::Always-Include-Phased-Updates=true` — same convention as the 09-12 entry. Worth a standing note: Ubuntu phasing defers security updates for a subset of machines; `update_system` should default to including phased updates when David approves "upgrade" of a scanned list, since the scan already enumerated them.

---

## 2026-09-18

### System Update — bubblewrap (security) + prior batches auto-applied

- `bubblewrap` 0.9.0-1ubuntu0.2 → 0.9.0-1ubuntu0.3 (security; applied manually)

- **Holds**: `kubelet`, `kubeadm`, `kubectl` v1.35.8 (unchanged)
- **Reboot**: not required
- **Cluster impact**: none (sandboxing tool, non-K8s)

### Notes
- Prior 09-16/09-17 security batches were auto-applied by `unattended-upgrades` overnight (not by ubuntu-desktop): polkit 124-2ubuntu1.24.04.3→.4 (6 pkg), krb5 1.20.1-6ubuntu2.8→2.10 (5 pkg), netplan 1.1.2-8ubuntu1~24.04.2→.3 (4 pkg), msr-tools 1.3-5build1→1.3-5ubuntu0.1, perl 5.38.2-3.2ubuntu0.4→0.6 (4 pkg), libsqlite3-0 3.45.1-1ubuntu2.7→2.8, libaom3 3.8.2-2ubuntu0.1→0.2.

---

## 2026-09-24

### System Update — 6 packages (kernel HWE + security) + reboot

- **Kernel HWE** 7.0.0-31 → **7.0.0-34** (3 packages):
  - `linux-image-generic-hwe-24.04`, `linux-headers-generic-hwe-24.04`, `linux-generic-hwe-24.04`
- **Linux tooling** (2 packages):
  - `linux-libc-dev` 6.8.0-139 → 6.8.0-142
  - `linux-tools-common` 6.8.0-139 → 6.8.0-142
- **sudo** (security) 1.9.15p5-3ubuntu5.24.04.2 → .3

- **Holds**: `kubelet`, `kubeadm`, `kubectl` v1.35.8 (unchanged)
- **Reboot**: required → done, to kernel **7.0.0-34**

### Cluster Health Gate
- ✅ Node Ready v1.35.8, kernel 7.0.0-34, 0 non-compliant pods, ArgoCD 8/8 Synced+Healthy (incl. 9router), flannel Running

### Notes
- Scope: package update only (NOT the 24.04→26.04 OS upgrade, which remains gated).
- Kernel HWE 7.0.0-34 applied now (previously deferred to fold into the OS upgrade) — David opted to update packages instead of waiting.
- Transient post-reboot: `kubectl get nodes` returned Forbidden for ~30s while RBAC settled; pods showed `Unknown` until kubelet reconciled. Resolved on its own after uncordon.

---

## 2026-09-26

### System Update — containerd 2.3.6 + 18 routine/security packages

- **Part B — containerd.io** (K8s runtime, node cordoned first):
  - `containerd.io` 2.3.5-1 → **2.3.6-1** (isolated; no drain — single-node convention)

- **Part A — Routine/security APT packages** (18 packages, incl. 9 phased-deferred forced in):
  - `curl` family (3): `curl`, `libcurl4t64`, `libcurl3t64-gnutls` 8.5.0-2ubuntu10.13 → 10.15 (security)
  - `apparmor` (2): `apparmor`, `libapparmor1` → 0ubuntu0.24.04.8 (security)
  - `libexpat1` 2.6.1-0ubuntu0.5 → 0.6 (security)
  - `libpcap0.8t64` 1.10.4-4.1 → 4.1ubuntu3.1 (security)
  - `audit` (2): `libaudit1`, `libaudit-common` 3.1.2-2.1build1.1 → 2.1ubuntu0.1
  - `xserver` (4): `xserver-xorg-core`, `-legacy`, `xserver-common`, `xserver-xephyr` 1ubuntu1.6 → 1.8
  - `gnome-shell` + `-common` 46.0-0ubuntu6~24.04.14 → .15
  - `dmidecode` 3.5-3ubuntu0.1 → 0.2; `libpciaccess0` 0ubuntu3.2 → .3
  - `linux-firmware-amd-graphics` 0ubuntu3.2 → 3.3

- **Holds**: `kubelet`/`kubeadm`/`kubectl` v1.35.8 (unchanged — candidate 1.35.9 deferred to Plan C)
- **Reboot**: flag set — cause `gnome-shell` only (desktop session; re-login suffices, no kernel/firmware driver). Deferred.

### Cluster Health Gate
- ✅ Node Ready v1.35.8 (one cordon cycle: B → A → gate → uncordon), 0 non-compliant pods, ArgoCD 8/8 Synced+Healthy, flannel Running, containerd v2.3.6

### Notes
- Phased forcing: `-o APT::Get::Always-Include-Phased-Updates=true` (standing convention, 3rd use).
- **K8s trio 1.35.9 NOT applied** — plan only (Plan C, k8s-selfhosted domain).
- Hashicorp apt repo (packer) key unverifiable: `NO_PUBKEY FC9CA96ACA026560` — repo stale; refresh key before next use; also pinned `noble` (codename migration needed at future OS upgrade).

---

## 2026-09-26 — K8s trio 1.35.9 + graceful cluster restart (Plan C, later same day)

- **K8s trio** `kubeadm` / `kubelet` / `kubectl` 1.35.8 → **1.35.9** (patch; executed by k8s-selfhosted — same owner as the 09-02 1.35.7→1.35.8 window; run details in k8s repo DECISIONS, commit `4fa2a92`)
- **Graceful restart** per Plan C v2: cordon → kubeadm upgrade apply v1.35.9 (static pods roll in place) → kubelet/kubectl 1.35.9 + restart → re-hold → graceful down (stop kubelet → stop containerd) → VM reboot → auto-up via systemd
- **Boot evidence**: at 2026-09-27 18:53 JST uptime was 1d14h56m → boot ≈ 2026-09-25 18:57 UTC
- **Holds re-applied**: `kubelet`/`kubeadm`/`kubectl` at **v1.35.9**
- **containerd**: v2.3.6 active (unchanged from earlier 09-26 window)

### Cluster Health Gate (independently verified by ubuntu-desktop, 2026-09-27)
- ✅ Node Ready v1.35.9 (uncordoned, schedulable), Server v1.35.9, 0 non-compliant pods, ArgoCD 8/8 Synced+Healthy (incl. 9router), flannel Running, containerd + kubelet active, holds intact, reboot flag cleared
- gnome-shell session flag from the B+A window cleared by this reboot (folded in per David's instruction)

---

---

## 2026-09-28

### 09-28 Power-Cut Outage — window missed, node recovered (V1-V8 CLOSED)
- **Timeline**: planned shutdown window 04:15 UTC never ran — the timer session died with zero P0-P4 steps (no fresh etcd snapshot, no cordon, no clean stop). Grid cut 05:00 UTC; power back ~07:10 UTC (16:10 JST); NUC BIOS 'After Power Failure = Stay Off' (bare metal, no hypervisor, no WoL) kept the node OFF until David powered it on manually 09:23 UTC.
- **VM-level gate**: uptime -s 09:23:08 UTC (continuous since David's power-on, no second blip), containerd + kubelet active, no reboot flag, holds intact (kubeadm/kubelet/kubectl at 1.35.9).
- **Cluster gate (verified independently by deepseek-minion 10:45-10:48 UTC, corroborated by k8s-selfhosted 10:49-10:55 UTC)**: node Ready v1.35.9, unschedulable unset, 26/26 pods Running, ArgoCD 8/8 Synced+Healthy, flannel Running, etcd healthy with clean snapshot recovery 13 s after power-on (snapshot-index 31483204, no WAL/corruption errors).
- **False 'node down since 10:15'**: Mac WARP manually disconnected — SSH path to 10.253.11.2 routes through WARP. External probe llm.kopidalar.id/v1/models answered (401 from 9router origin) throughout. No node-side outage.
- **Records**: k8s-selfhosted .agents/DECISIONS.md '2026-09-28: 09-28 Power-Cut Outage Recovery (V1-V8) — CLOSED' + KB decisions entry. Recommendation: set NUC BIOS Power -> After Power Failure to Power On for self-healing.

---

## 2026-09-30

### 6 security packages applied by unattended-upgrades (pre-approval)
- **Finder**: ubuntu-desktop daily scan 09-29 flagged 6 upgradable, all `noble-security`: `dracut-install` 060+5-1ubuntu3.3→.4, `libfreerdp3-3`/`libfreerdp-server3-3`/`libwinpr3-3` 3.31.0→3.32.0, `python3-jwt` 2.7.0-1ubuntu0.1→.2, `python3-requests` 2.31.0+dfsg-1ubuntu1.1→.2
- **Applier**: Ubuntu `unattended-upgrades` (auto security-only), 2026-09-30 06:40:33-40 UTC — ran after the scan, before David's approval. Manual `apt upgrade -y` on approval was a no-op (0 upgraded).
- **Post-check (ubuntu-desktop)**: dpkg confirms all 6 at target versions, apt 0 upgradable, holds intact (trio v1.35.9), no reboot flag, node Ready v1.35.9, 0 non-running pods.
- **Implication**: unattended-upgrades may auto-apply security-only batches before approval lands — future scan reports may show security items already resolved same-day.
