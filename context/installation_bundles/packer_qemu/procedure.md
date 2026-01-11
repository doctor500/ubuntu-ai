# Packer + QEMU Installation Procedure

## Pre-Execution: Verify Procedure is Current

**Official Documentation:**
- Packer: https://developer.hashicorp.com/packer/install
- QEMU Packer Plugin: https://github.com/hashicorp/packer-plugin-qemu

**Last Verified:** 2026-01-08

---

## 0. Select Execution Target

**Default:** VM managed by this project (from `user_data.json`).

### Load default target

```bash
cat context/user_data.json
```

Extract: `vm_ip`, `vm_username`, `vm_hostname`

### Ask user

```
Execution target: {{vm_hostname}} ({{vm_ip}})

Use this target? [Y/n]
```

**Store target for this session:**
- `TARGET_IP={{vm_ip}}`
- `TARGET_USER={{vm_username}}`

---

## 1. Check Existing Installation (on target VM)

```bash
# Check Packer
ssh {{TARGET_USER}}@{{TARGET_IP}} "which packer && packer --version || echo 'NOT_INSTALLED'"

# Check QEMU
ssh {{TARGET_USER}}@{{TARGET_IP}} "which qemu-system-x86_64 && qemu-system-x86_64 --version || echo 'NOT_INSTALLED'"
```

**If both installed:** Skip to verification (Step 4).

---

## 2. Install QEMU/KVM (on target VM)

### Install QEMU packages

```bash
ssh {{TARGET_USER}}@{{TARGET_IP}} "sudo apt-get update && sudo apt-get install -y qemu-system-x86 qemu-utils libvirt-daemon-system libvirt-clients virtinst"
```

### Add user to groups

```bash
ssh {{TARGET_USER}}@{{TARGET_IP}} "sudo usermod -aG libvirt,kvm {{TARGET_USER}}"
```

---

## 3. Install Packer (on target VM)

### Add HashiCorp GPG key and repository

```bash
ssh {{TARGET_USER}}@{{TARGET_IP}} "wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg"
```

```bash
ssh {{TARGET_USER}}@{{TARGET_IP}} 'echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list'
```

### Update and install

```bash
ssh {{TARGET_USER}}@{{TARGET_IP}} "sudo apt-get update && sudo apt-get install -y packer"
```

---

## 4. Verification (on target VM)

```bash
# Packer version
ssh {{TARGET_USER}}@{{TARGET_IP}} "packer --version"
# Expected: Packer v1.x.x

# QEMU version
ssh {{TARGET_USER}}@{{TARGET_IP}} "qemu-system-x86_64 --version"
# Expected: QEMU emulator version X.X.X

# KVM check
ssh {{TARGET_USER}}@{{TARGET_IP}} "kvm-ok || echo 'KVM support check'"
```

---

## 5. Post-Install Notice

**AI Agent Action:** Display this message after successful installation:

```
✅ Packer + QEMU/KVM installed successfully on {{vm_hostname}}!

This bundle is OPTIONAL and NOT automatically added to autoinstall.yaml.
The tools are available for E2E testing via the e2e_autoinstall_test procedure.

Note: User may need to logout/login for group changes to take effect.

Next steps:
  → Return to e2e_autoinstall_test procedure to continue testing
```

---

## Uninstall Section (on target VM)

### Remove Packer

```bash
ssh {{TARGET_USER}}@{{TARGET_IP}} "sudo apt-get remove --purge packer && sudo rm -f /etc/apt/sources.list.d/hashicorp.list /usr/share/keyrings/hashicorp-archive-keyring.gpg && sudo apt-get update"
```

### Remove QEMU (careful - may affect other services)

```bash
ssh {{TARGET_USER}}@{{TARGET_IP}} "sudo apt-get remove --purge qemu-system-x86 qemu-utils"
```

---

## Troubleshooting

### QEMU Permission Denied

```bash
ssh {{TARGET_USER}}@{{TARGET_IP}} "groups | grep -E 'kvm|libvirt'"
# If groups missing, re-run usermod and logout/login
```

### KVM Not Available

```bash
ssh {{TARGET_USER}}@{{TARGET_IP}} "egrep -c '(vmx|svm)' /proc/cpuinfo"
# Expected: Number > 0
```

If 0: Enable virtualization in BIOS/UEFI settings.

### Passwordless Sudo Recommendation

If multiple sudo commands prompt for password, consider running `passwordless_sudo` procedure first.
