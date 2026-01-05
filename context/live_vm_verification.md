# Live VM Verification & Synchronization Procedure

This document outlines the procedures for verifying the state of the live Ubuntu VM and ensuring it synchronizes with the `autoinstall.yaml` configuration.

## ⚠️ Important: Dynamic Configuration
**Do not hardcode sensitive values.** Before executing commands, load `context/user_data.json` to retrieve:
- `vm_ip`
- `vm_username`
- `vm_hostname`

## Target VM Information
- **IP Address:** `{{vm_ip}}` (Refer to `context/user_data.json`)
- **Hostname:** `{{vm_hostname}}` (Refer to `context/user_data.json`)
- **Username:** `{{vm_username}}` (Refer to `context/user_data.json`)
- **Password:** Manual entry required (or use `sshpass` if automated).

## State Verification
To verify the current state of the VM (hostname, OS version, installed packages) against the configuration:

### 1. Connectivity Check
```bash
ping -c 3 {{vm_ip}}
```

### 2. State Inspection Command
Run the following SSH command to retrieve critical system information. This checks the hostname, OS release info, locale, and presence of key packages managed by `autoinstall.yaml`.

```bash
ssh {{vm_username}}@{{vm_ip}} "hostname && cat /etc/os-release && locale && dpkg -l | grep -E 'build-essential|git|ubuntu-desktop' && systemctl is-enabled ssh"
```

### 3. Comparison Logic
Compare the output of the command above with `context/autoinstall.yaml`:

| Check | VM Output | Config File (`identity`, `packages`) |
| :--- | :--- | :--- |
| **Hostname** | Should match `{{vm_hostname}}` | `identity: hostname` |
| **Desktop** | `ubuntu-desktop` or `ubuntu-desktop-minimal` | `packages` list |
| **Tools** | `git`, `build-essential`, etc. | `packages` list |
| **SSH** | `enabled` | `ssh: install-server: true` |

## Synchronization Workflow
1.  **Analyze Request:** Determine if the goal is to update the *VM* to match the *Config* (Provisioning) or update the *Config* to match the *VM* (Baselining).
2.  **Edit Config:** Modify `context/autoinstall.yaml` as needed.
3.  **Validate Syntax:** Run the procedure in `context/validation_procedure.md`.
4.  **Verify Live:** Run the inspection command above to confirm alignment (if baselining) or identify gaps (if provisioning).