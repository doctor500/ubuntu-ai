# E2E Autoinstall Test Procedure

## Quick Start (Automated)

Use the bundled script for fast, repeatable testing:

```bash
# From project root - run full E2E test with VNC monitoring
./context/procedures/e2e_autoinstall_test/files/run-e2e-test.sh

# Other actions
./run-e2e-test.sh autoinstall.yaml vnc     # Reconnect VNC to running build
./run-e2e-test.sh autoinstall.yaml logs    # Tail packer logs in real-time
./run-e2e-test.sh autoinstall.yaml status  # Check if build is running
./run-e2e-test.sh autoinstall.yaml stop    # Stop running build

# Custom target VM
TARGET_VM=user@192.168.1.100 ./run-e2e-test.sh
```

---

## General Protocol: Pre-Procedure

Run `validate_config` procedure first to ensure autoinstall.yaml syntax is valid.

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

**If user confirms (Y):** Continue with default target.

**If user changes (n):** Gather new target interactively:
1. Ask for IP address
2. Ask for SSH username
3. Test SSH connectivity: `ssh {{username}}@{{ip}} "echo connected"`
4. If fails, troubleshoot or ask for correction

**Store target for this session:**
- `TARGET_IP={{vm_ip}}`
- `TARGET_USER={{vm_username}}`

---

## 1. Verify Dependencies (on target VM)

All commands in this section run on **target VM via SSH**.

### Check Packer

```bash
ssh {{TARGET_USER}}@{{TARGET_IP}} "which packer && packer --version"
```

### Check QEMU

```bash
ssh {{TARGET_USER}}@{{TARGET_IP}} "which qemu-system-x86_64 && qemu-system-x86_64 --version"
```

**If either missing:**
- Stop this procedure
- Run `installation_bundles/packer_qemu` procedure on the target VM
- Return here after installation completes

**If both installed:** Proceed to Step 2.

---

## 2. Transfer Test Files to VM

### Create test directory on VM

```bash
ssh {{TARGET_USER}}@{{TARGET_IP}} "mkdir -p ~/autoinstall-e2e-test"
```

### Copy Packer template

```bash
scp context/procedures/e2e_autoinstall_test/files/packer-template.pkr.hcl \
    {{TARGET_USER}}@{{TARGET_IP}}:~/autoinstall-e2e-test/
```

### Copy validation script

```bash
scp context/procedures/e2e_autoinstall_test/files/test-validation.sh \
    {{TARGET_USER}}@{{TARGET_IP}}:~/autoinstall-e2e-test/
```

### Copy autoinstall.yaml

```bash
scp context/autoinstall.yaml \
    {{TARGET_USER}}@{{TARGET_IP}}:~/autoinstall-e2e-test/
```

---

## 3. Check Existing Packer Configuration

```bash
ssh {{TARGET_USER}}@{{TARGET_IP}} "ls ~/autoinstall-e2e-test/packer-template.pkr.hcl"
```

**If exists:** Ask user: "Packer config exists on VM. Reuse it? [Y/n]"
- If yes: Skip config modifications
- If no: Re-transfer template from Step 2

---

## 4. Configure Packer Template (Optional)

### Default Configuration Values

| Setting | Default | Notes |
|---------|---------|-------|
| Ubuntu ISO | 24.04.1 Desktop | Matches project target |
| RAM | 4096 MB | Minimum for desktop |
| CPUs | 2 | Reasonable build speed |
| Disk | 25600 MB | Allows for packages |
| Boot Wait | 10s | Time for GRUB menu |

### Ask user for modifications

**AI Agent Action:**
1. "Change Ubuntu ISO version? [current: 24.04.1]"
2. "Change VM resources? [current: 4GB RAM, 2 CPU, 25GB disk]"
3. "Adjust boot wait time? [current: 10s]"

If changes requested: Edit template on VM via SSH or re-transfer modified version.

### Configure SSH credentials

**Critical:** Packer template needs credentials matching autoinstall.yaml.

Ask user:
- "SSH username in autoinstall.yaml identity section?"
- "SSH password for that user?"

Update packer-template.pkr.hcl variables on VM.

---

## 5. Run E2E Test (on target VM)

### Initialize Packer plugins

```bash
ssh {{TARGET_USER}}@{{TARGET_IP}} "cd ~/autoinstall-e2e-test && packer init ."
```

### Validate Packer template

```bash
ssh {{TARGET_USER}}@{{TARGET_IP}} "cd ~/autoinstall-e2e-test && packer validate -var 'autoinstall_path=autoinstall.yaml' ."
```

**If validation fails:** Fix errors before proceeding.

### Start the build

```bash
ssh {{TARGET_USER}}@{{TARGET_IP}} "cd ~/autoinstall-e2e-test && packer build -var 'autoinstall_path=autoinstall.yaml' ."
```

**Expected duration:** 10-30 minutes depending on:
- ISO download (first run only, ~5GB)
- Number of packages in autoinstall.yaml
- Complexity of late-commands

---

## 6. Analyze Results

### Success Output

```
Build 'virtualbox-iso.ubuntu-autoinstall-test' finished after X minutes.
==> Builds finished. The artifacts of successful builds are:
```

**AI Agent Action:** Report:
```
✅ E2E Test PASSED

All late-commands executed successfully.
Build completed in X minutes.
```

### Failure Output

Look for `Error` or `Failed` in Packer logs.

**AI Agent Action:** Parse and report:
```
❌ E2E Test FAILED

Error detected:
  Command: [exact command that failed]
  Exit code: [code]
  Output: [relevant error message]

Suggested fix: [actionable recommendation]
```

---

## 7. Cleanup (Optional)

### Remove test artifacts on VM

```bash
ssh {{TARGET_USER}}@{{TARGET_IP}} "rm -rf ~/autoinstall-e2e-test/output-* ~/autoinstall-e2e-test/packer_cache"
```

### Remove entire test directory

```bash
ssh {{TARGET_USER}}@{{TARGET_IP}} "rm -rf ~/autoinstall-e2e-test"
```

---

## General Protocol: Post-Procedure

If issues were found:
1. Fix issues in `autoinstall.yaml` (locally)
2. Run `validate_config` procedure
3. Update `change_log.md` with fixes
4. Re-run this E2E test

---

## Troubleshooting

### SSH connection to target failed

```bash
# Test connectivity
ssh -v {{TARGET_USER}}@{{TARGET_IP}}
```

**Solutions:**
- Verify VM is running
- Check IP address in user_data.json
- Run ssh_key_auth procedure if needed

### Packer timeout waiting for SSH (in nested VM)

**Cause:** Nested VM installation didn't complete.

**Solutions:**
1. Increase `ssh_timeout` in packer-template.pkr.hcl
2. Check autoinstall.yaml has `ssh: install-server: true`
3. Verify late-commands don't hang

### VirtualBox nested virtualization

**Note:** Running VirtualBox inside a VM requires nested virtualization support.

**Check on target VM:**
```bash
ssh {{TARGET_USER}}@{{TARGET_IP}} "egrep -c '(vmx|svm)' /proc/cpuinfo"
```

If 0: Enable nested virtualization on the host hypervisor.

### Passwordless Sudo Recommendation

For smoother execution, consider running `passwordless_sudo` procedure on target VM first.
