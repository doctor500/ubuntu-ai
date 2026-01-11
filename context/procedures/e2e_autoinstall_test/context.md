# E2E Autoinstall Test Procedure Context

## Overview
End-to-end testing procedure for validating autoinstall.yaml configurations by building a real Ubuntu VM using Packer and QEMU/KVM.

## Goal
Catch errors in autoinstall.yaml before deployment, especially in `late-commands` post-installation scripts.

## Triggers
- Changes to autoinstall.yaml
- Adding new installation bundles
- Before deploying to production VM
- CI/CD pipeline validation

## Prerequisites
See common_patterns.md#standard-prerequisites

**Specific:**
- Packer installed (via `packer_qemu` bundle)
- QEMU/KVM installed (via `packer_qemu` bundle)
- autoinstall.yaml exists and is valid

## Logic
1. **Select target:** Ask user to confirm/change execution target (default: VM from user_data.json)
2. Run validate_config procedure first (general protocol)
3. Verify Packer + QEMU on **target VM** via SSH → Redirect to bundle if missing
4. Transfer test files to target VM
5. Check for existing packer config on VM → Reuse if exists
6. Ask user for config modifications if needed
7. Run Packer build on target VM via SSH
8. Analyze results and report success/failure
9. Update change_log.md if issues found (general protocol)

## Related Files
- `files/packer-template.pkr.hcl` - Packer build configuration (QEMU)
- `files/test-validation.sh` - Post-install validation script
- `files/run-e2e-test.sh` - Automated test runner script
- `installation_bundles/packer_qemu/` - Dependencies

## AI Agent Notes

**Safety:** ASK | Creates VM, runs installation

**Interaction:**
- **First step:** Ask user to confirm/change execution target
- Default: VM from user_data.json
- All commands execute on target VM via SSH
- Verify dependencies via SSH, redirect to bundle if missing
- Reuse existing packer config if found on VM
- Ask before modifying config (ISO version, resources)
- Report results clearly with actionable fixes

**Issues:** See common_patterns.md#network-timeout, #yaml-syntax-error

**Specific:**
- Build takes 10-30 minutes depending on late-commands
- QEMU uses KVM for acceleration (native performance)
- Check Packer logs for late-command failures
- Exit code 0 = all scripts passed
- Pre-run: validate_config | Post-run: update change_log.md if fixes needed

## Quick Start (Automated)

```bash
# Run E2E test with VNC monitoring
./context/procedures/e2e_autoinstall_test/files/run-e2e-test.sh

# Available actions
./run-e2e-test.sh autoinstall.yaml run          # Start new build + VNC
./run-e2e-test.sh autoinstall.yaml status       # Check build status
./run-e2e-test.sh autoinstall.yaml console      # View serial console output
./run-e2e-test.sh autoinstall.yaml console-tail # Tail serial console live
./run-e2e-test.sh autoinstall.yaml logs         # Tail packer logs
./run-e2e-test.sh autoinstall.yaml vnc          # Reconnect VNC
./run-e2e-test.sh autoinstall.yaml stop         # Stop build
```

## Key Learnings

**2-Phase Approach (CRITICAL):**
- `ubuntu-desktop-minimal` breaks SSH password authentication when installed during autoinstall
- Root cause: GDM3/PAM configuration changes interfere with SSH password auth
- Solution: Install desktop in Phase 2 via first-boot systemd service AFTER SSH is available
- Template: `context/autoinstall.example.yaml` (unified template with Phase 2 built-in)

**Heredoc Escaping (CRITICAL):**
- Heredocs (`<< EOF`) do NOT work reliably in autoinstall late-commands
- Shell escaping through YAML → curtin → bash layers corrupts content
- **Solution:** Use simple echo commands to build scripts line by line

**External Package Repositories:**
- Packages like `containerd.io` (Docker) and `kubelet/kubeadm/kubectl` (Kubernetes) are NOT in Ubuntu default repos
- Add external repos in `early-commands` section (runs before `packages:` section)
- Example repos needed: Docker repo for containerd.io, Kubernetes repo for k8s tools

**SSH Credentials:**
- Packer's `ssh_password` must match the password in `autoinstall.yaml` identity section
- Generate password hash with: `echo 'password' | openssl passwd -6 -stdin`
- **CRITICAL:** When creating autoinstall.yaml, use single-quoted heredoc (`<< 'EOF'`) to prevent `$` expansion in password hash

**Serial Console for Debugging:**
- Packer template includes `-serial file:/tmp/qemu-console.log` for VM output
- Boot command includes `console=ttyS0,115200` to redirect kernel output
- Use `console` or `console-tail` script actions to view output without VNC screenshots

