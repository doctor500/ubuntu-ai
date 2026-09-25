# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Created `update_system` procedure for package and bundle updates with version tracking
  - Supports APT, Homebrew, and bundle-specific updates
  - Integrates with changelog for version history
- Created `reboot_vm` procedure for graceful single-node k8s VM reboot
  - Cordon -> reboot -> verify (6 gates) -> uncordon
  - Documents the 2026-08-11 cordon-left-behind failure mode

### Changed
- Reorganized `common_patterns.md` procedure categories (Init/Config/VM/Security/Maintenance)
- Updated README.md with complete procedure list (14 procedures, 4 bundles)

### Applied (VM System Update - 2026-09-26)
- **containerd.io** 2.3.5-1 → 2.3.6-1 (runtime; node cordoned first, no drain)
- **18 routine/security APT packages** (curl family, apparmor, expat, pcap, audit, xserver, gnome-shell, linux-firmware-amd-graphics; 9 phased forced per convention)
- Post-update verification: node Ready v1.35.8, 0 non-compliant pods, ArgoCD 8/8 Synced+Healthy, flannel Running
- Holds unchanged: kubelet/kubeadm/kubectl v1.35.8 (candidate 1.35.9 deferred — Plan C)
- Reboot flag set by gnome-shell only (session restart suffices; deferred)
- See `context/vm_update_log.md` for full package details

### Applied (VM System Update - 2026-09-24)
- **6 APT packages** upgraded: kernel HWE 7.0.0-31 → 7.0.0-34 (3 pkg), linux-libc-dev + linux-tools-common 6.8.0-139 → 6.8.0-142, sudo security
- **Reboot** to kernel 7.0.0-34 (from 7.0.0-31); node cordoned, graceful reboot, uncordoned
- **Post-reboot verification**: node Ready v1.35.8, 0 non-compliant pods, ArgoCD 8/8 Synced+Healthy (incl. 9router), flannel Running
- **Holds** unchanged: kubelet/kubeadm/kubectl v1.35.8
- **Scope note**: package update only — the 24.04→26.04 OS upgrade remains gated (meta-release-lts `Supported: 0`)
- See `context/vm_update_log.md` for full package details

### Applied (VM System Update - 2026-09-11)
- **containerd.io** 2.3.4-2 → 2.3.5-1 (runtime; node cordoned first)
- **~29 routine/security APT packages** upgraded (libc6 family, python3.12, wireless-regdb, linux-firmware split, base-files, language-packs, etc.)
- **Reboot** to kernel 7.0.0-31 (from 7.0.0-30); node cordoned, graceful reboot, uncordoned
- **Post-reboot verification**: node Ready v1.35.8, 0 non-compliant pods, ArgoCD apps Synced+Healthy, containerd v2.3.5, kube-proxy at 10.253.11.2:6443
- **Holds** unchanged: kubelet/kubeadm/kubectl v1.35.8
- See `context/vm_update_log.md` for full package details

### Applied (VM System Update - 2026-09-02)
- **25 routine APT packages** upgraded (snapd, python3.12, krb5, ncurses, libgcrypt20, console-setup, etc.)
- **containerd.io** 2.3.3 → 2.3.4 (runtime; node cordoned + drained first)
- **K8s trio** kubelet/kubeadm/kubectl 1.35.7 → 1.35.8 (kubeadm patch upgrade, k8s-selfhosted)
- **Reboot** to kernel 7.0.0-30; node cordoned, drained, graceful reboot, uncordoned
- **Post-reboot verification**: node Ready v1.35.8, 0 non-compliant pods, ArgoCD 7/7 Synced+Healthy, flannel Running, containerd v2.3.4
- **Holds re-applied** at v1.35.8
- See `context/vm_update_log.md` for full package details

### Applied (VM System Update - 2026-08-11)
- **111 APT packages** upgraded (systemd, GDM, GNOME, containerd, QEMU, packer, +59 libs)
- **k9s** 0.50.18 → 0.51.0 (Homebrew)
- **Reboot** to kernel 7.0.0-28 (from 6.17.0-35); node cordoned, graceful reboot
- **Post-reboot verification** (per k8s-selfhosted KB): all 7 ArgoCD apps Healthy, in-cluster VIP OK, no stale iptables, kube-proxy confirmed at 10.253.11.2
- See `context/vm_update_log.md` for full package details

### Applied (VM System Update - 2026-01-20)
- See `context/vm_update_log.md` for detailed package updates (3 packages updated)

## [0.4.3] - 2026-01-16

### Fixed (Critical Infrastructure)
- **Container Extraction**: Added `pigz` package to fix container image extraction errors (required by containerd).
- **Storage**: Installed **Local Path Provisioner** and configured as default StorageClass to fix `Pending` PVCs.

### Applied
- Installed `pigz` on live VM.
- Deployed Local Path Provisioner to live Kubernetes cluster.
- Verified n8n pods recovered from startup errors.

## [0.4.2] - 2026-01-16

### Applied (VM System Update)
- See `context/vm_update_log.md` for detailed package updates (13 packages updated)

### Notes
- GDM packages (gdm3, gir1.2-gdm-1.0, libgdm1) deferred due to Ubuntu phasing
- Kubernetes packages (kubelet, kubeadm, kubectl) remain held at v1.31.14

## [0.4.1] - 2026-01-07

### Optimized
- **Context Files**: Reduced total project context size by ~25% (400+ lines removed) to improve AI agent efficiency.
- **Refactoring**: Compacted all 14 `context.md` files into a standardized, token-efficient tabular format.
- **Performance**: Reduced cognitive load for AI agents by replacing prose with strict decision tables and pointers.

### Added
- Added `k9s` (Kubernetes TUI) to Shell Tools bundle
- **Common Patterns**: Added reusable templates in `context/common_patterns.md`:
  - `Pre-Execution Check`: Standardized external dependency verification.
  - `AI Agent Notes`: Uniform format for safety, interaction, and issue handling.


### Applied
- Installed `k9s` v0.50.16 on current VM via Homebrew
### Changed
- **Safety**: Centralized safety definitions in `common_patterns.md` and referenced them in procedures, ensuring consistency.

## [0.4.0] - 2026-01-07

### Added
- Added `k9s` (Kubernetes TUI) to Shell Tools bundle
- Created `context/installation_bundles/kubeadm/` for single-node Kubernetes
- Created `context/installation_bundles/shell_tools/` for Homebrew + Oh My Zsh
  - `context.md`: Overview, single vs multi-node comparison, components
  - `procedure.md`: Step-by-step installation with system configuration
- Installed nerdctl v2.2.1 (Docker-compatible CLI for containerd)
- Added k8s-init-single-node.sh convenience script to autoinstall
- Added Kubernetes late-commands to autoinstall.yaml:
  - Kubernetes apt repository + GPG key
  - Kernel modules (overlay, br_netfilter)
  - Sysctl settings (IP forwarding)
  - Swap disabled
  - Containerd configuration (SystemdCgroup)
  - nerdctl installation
  - Kubelet enabled

### Applied (VM Configuration)
- Installed Kubernetes v1.31.14 on current VM
- Initialized single-node cluster with kubeadm
- Installed Flannel CNI for pod networking
- Verified: kubectl get nodes shows Ready status
- Installed nerdctl v2.2.1


### Applied
- Installed `k9s` v0.50.16 on current VM via Homebrew
### Changed
- Updated README.md with kubeadm bundle documentation

## [0.3.0] - 2026-01-06

### Added
- Added `k9s` (Kubernetes TUI) to Shell Tools bundle
- Created `context/procedures/passwordless_sudo/` for passwordless sudo configuration
  - `context.md`: Security considerations, trade-offs, triggers
  - `procedure.md`: Setup instructions for current VM and autoinstall integration
- Created `.geminiinclude` to allow AI access to gitignored config files
- Added passwordless sudo late-command to `autoinstall.yaml`


### Applied
- Installed `k9s` v0.50.16 on current VM via Homebrew
### Changed
- Updated `autoinstall.yaml` with late-commands section for post-installation configuration
- Optimized all 10 procedure context files (1,091 → 723 lines, -34% reduction)
- Created `context/common_patterns.md` for shared documentation patterns

### Applied (VM Configuration)
- Configured passwordless sudo on current VM (davidlay@10.1.21.29)
- Created `/etc/sudoers.d/90-nopasswd-davidlay` with NOPASSWD rule
- Verified with `sudo -n whoami` returning `root`

### Security
- Documented security trade-offs for passwordless sudo (convenience vs security)
- Recommended use cases: development VMs, local testing, single-user workstations
- Not recommended for: production servers, shared systems

## [0.2.0] - 2026-01-06

### Added
- Added `k9s` (Kubernetes TUI) to Shell Tools bundle
- Created `context/autoinstall.example.yaml` as safe template with dummy/placeholder values
- Created `context/procedures/init_autoinstall/` procedure for handling missing config files
- Added interactive customization workflow for hostname, username, and password
- Added password hash generation guidance using `mkpasswd -m sha-512`
- Added comprehensive Quick Start guide in README.md


### Applied
- Installed `k9s` v0.50.16 on current VM via Homebrew
### Changed
- Updated `.gitignore` to exclude `.subiquity/` directory (contains network configs and WiFi passwords)
- Updated `.gitignore` to exclude `context/autoinstall.yaml` (contains personalized configuration)
- Updated `README.md` to document the template system and initialization workflow
- Updated `README.md` Project Structure section to clarify gitignored files
- Reset git history to remove sensitive data - created new clean initial commit (ed6ad94)
- Reformatted `change_log.md` to follow Keep a Changelog v1.1.0 standard
- Updated `context/procedures/init_change_log/` to use Keep a Changelog format

### Removed
- Removed `.subiquity/` files from git tracking (contained WiFi passwords and IP addresses)
- Removed `context/autoinstall.yaml` from repository (now gitignored for security)
- Deleted old `main` branch containing sensitive data (commit 091408b)

### Security
- **CRITICAL**: Identified and removed WiFi password from `.subiquity/etc/netplan/00-installer-config.yaml`
- Identified and removed IP address `10.0.2.15` from network configuration files
- Identified and removed VM IP address `10.1.21.29` from git history
- Excluded personal hostname `davidlay-NUC13ANKi7` and username `davidlay` from repository
- Implemented template-based configuration system to prevent accidental sensitive data commits
- Verified no sensitive data remains in git repository or commit history

## [0.1.0] - 2026-01-05

### Added
- Added `k9s` (Kubernetes TUI) to Shell Tools bundle
- Initial project structure and documentation
- Created `context/autoinstall.yaml` baseline configuration for Ubuntu Desktop VM
- Created `context/validation_procedure.md` for autoinstall config validation
- Created `context/live_vm_verification.md` for VM state verification procedures
- Created `context/autoinstall-schema.json` validation schema
- Added Docker installation bundle in `context/installation_bundles/docker/`
- Created `context/user_data.json` to store VM-specific details (IP, hostname, username)
- Created `context/procedures/exclude_bundles/` for generating variant configs
- Created `context/procedures/init_user_data/` for initializing sensitive data file
- Created `context/procedures/init_change_log/` for changelog initialization
- Created `context/procedures/maintain_docs/` for README synchronization
- Created `context/procedures/ssh_key_auth/` for passwordless SSH setup
- Created `context/installation_bundles/README.md` documenting bundle standards
- Created `README.md` with project overview and quick start guide
- Added packages to autoinstall config: `ubuntu-desktop-minimal`, `git`, `neofetch`, `net-tools`
- Added Docker packages: `docker-ce`, `docker-ce-cli`, `containerd.io`, `docker-buildx-plugin`, `docker-compose-plugin`


### Applied
- Installed `k9s` v0.50.16 on current VM via Homebrew
### Changed
- Updated `autoinstall.yaml` to match target VM state (hostname, packages)
- Updated `autoinstall.yaml` package list: replaced `ubuntu-desktop` with `ubuntu-desktop-minimal`
- Generalized context files to use `user_data.json` for VM-specific information
- Updated `README.md` to remove personalized hostname for public repository suitability

### Fixed
- N/A (initial release)

### Security
- Enabled SSH key authentication for VM access
- Validated SSH key-based passwordless login functionality
- Successfully installed and verified system dependencies for validation

### Completed
- **Packer + VirtualBox E2E Testing Bundle**: Successfully installed (2026-01-08)
  - VirtualBox 7.0 packages installed but kernel modules not loaded
  - **Action Required**: Disable Secure Boot in BIOS, then:
    1. `sudo dpkg --configure -a`
    2. `sudo modprobe vboxdrv`
    3. `sudo usermod -aG vboxusers davidlay`
  - After Secure Boot disabled, continue with Packer installation
  - Then resume `e2e_autoinstall_test` procedure

### Added
- Created `context/installation_bundles/packer_virtualbox/` for E2E testing tools
  - `context.md`: Optional bundle for Packer + VirtualBox
  - `procedure.md`: SSH-based installation with target selection
- Created `context/procedures/e2e_autoinstall_test/` for autoinstall.yaml validation
  - `context.md`: E2E testing procedure context
  - `procedure.md`: SSH-based test workflow
  - `files/packer-template.pkr.hcl`: Packer HCL template
  - `files/test-validation.sh`: Post-install validation script
