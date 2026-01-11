# Packer + QEMU Installation Bundle Context

## Overview
Tooling for E2E testing of autoinstall.yaml configurations using Packer and QEMU/KVM. Uses native Linux virtualization for better performance.

## Goal
Enable automated validation of autoinstall.yaml by building and testing Ubuntu images locally using QEMU/KVM.

## Triggers
- User wants to test autoinstall.yaml before deployment
- Setting up E2E testing for configuration validation
- Preparing CI/CD pipeline for image building

## Prerequisites
See common_patterns.md#standard-prerequisites

**Specific:**
- Ubuntu 22.04+ host
- 20GB+ disk space
- 4GB+ RAM (8GB recommended)
- CPU with virtualization (VT-x/AMD-V)
- Sudo access

## Components

| Package | Purpose | Source |
|---------|---------|--------|
| packer | Image builder | HashiCorp APT repo |
| qemu-system-x86 | QEMU emulator | Ubuntu repo |
| qemu-utils | QEMU tools | Ubuntu repo |
| libvirt-daemon-system | Libvirt daemon | Ubuntu repo |
| virtinst | VM provisioning | Ubuntu repo |

## Logic
1. **Select target:** Ask user to confirm/change execution target (default: VM from user_data.json)
2. Check if already installed on target VM via SSH
3. Install QEMU/KVM packages via SSH
4. Install Packer from HashiCorp repo via SSH
5. Add user to libvirt/kvm groups
6. Verify installation via SSH
7. Inform user about optional autoinstall inclusion

## Related Files
- `procedure.md` - Step-by-step installation (all SSH-based)
- `procedures/e2e_autoinstall_test/` - Uses this bundle

## AI Agent Notes

**Safety:** ASK | Requires sudo on target VM, adds external repositories

**Interaction:**
- **First step:** Ask user to confirm/change execution target
- Default: VM from user_data.json
- All commands execute on target VM via SSH
- After install: Inform user bundle is optional (not auto-added to autoinstall.yaml)

**Issues:** See common_patterns.md#network-timeout, #permission-denied

**Specific:**
- QEMU/KVM is native to Linux, better performance than VirtualBox
- No conflict with existing KVM usage
- Verify: `packer --version`, `qemu-system-x86_64 --version` (via SSH)
- Uninstall: See procedure.md#uninstall-section
