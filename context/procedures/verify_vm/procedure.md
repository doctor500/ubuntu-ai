# VM Verification Procedure

## 1. Verify Prerequisites

### Check user_data.json exists
```bash
ls context/user_data.json
```

If missing, run the init_user_data procedure first.

### Check autoinstall.yaml exists
```bash
ls context/autoinstall.yaml
```

If missing, run the init_autoinstall procedure first.

## 2. Load VM Connection Details

```bash
cat context/user_data.json
```

Extract the following values:
- `vm_ip` - IP address of the target VM
- `vm_username` - SSH username
- `vm_hostname` - Expected hostname

**Note:** Replace `{{vm_ip}}`, `{{vm_username}}`, and `{{vm_hostname}}` placeholders in commands below with actual values from user_data.json.

## 3. Test Connectivity

### Ping the VM
```bash
ping -c 3 {{vm_ip}}
```

**Expected output:** 3 packets transmitted, 3 received, 0% packet loss

If ping fails:
- Verify VM is powered on
- Check network configuration
- Confirm IP address is correct in user_data.json

## 4. Gather Current VM State

### Run state inspection command
```bash
ssh {{vm_username}}@{{vm_ip}} "hostname && cat /etc/os-release && locale && dpkg -l | grep -E 'ubuntu-desktop-minimal|git|docker-ce|neofetch|net-tools' && systemctl is-enabled ssh"
```

This command retrieves:
- Current hostname
- OS release information
- Locale settings
- Installed packages (matching autoinstall.yaml)
- SSH service status

**Expected output:**
- Hostname matching `{{vm_hostname}}`
- OS information (Ubuntu version)
- Installed packages listed with version numbers
- `enabled` for SSH service

## 5. Compare Against Configuration

### Manual Comparison Table

Compare the SSH output with `context/autoinstall.yaml`:

| Check | VM Output | Config File | Match? |
|:------|:----------|:------------|:-------|
| **Hostname** | `<from ssh>` | `identity: hostname` | ✓/✗ |
| **Desktop** | `ubuntu-desktop-minimal` | `packages` list | ✓/✗ |
| **Git** | `ii git ...` | `packages` list | ✓/✗ |
| **Docker CE** | `ii docker-ce ...` | `packages` list | ✓/✗ |
| **Neofetch** | `ii neofetch ...` | `packages` list | ✓/✗ |
| **Net-tools** | `ii net-tools ...` | `packages` list | ✓/✗ |
| **SSH** | `enabled` | `ssh: install-server: true` | ✓/✗ |

### Automated Comparison (Optional)

For automated comparison, parse both the SSH output and autoinstall.yaml programmatically to identify:
- **Missing packages:** In config but not on VM
- **Extra packages:** On VM but not in config (informational)
- **Hostname mismatch:** Different from config
- **Service status:** Services not enabled as expected

## 6. Report Results

Present findings to user:

```
VM Verification Results:
========================
Target: {{vm_ip}} ({{vm_hostname}})

✓ Hostname: Matches
✓ OS: Ubuntu 24.04 LTS
✓ SSH Service: Enabled
✓ Packages (5/5 matched):
  - ubuntu-desktop-minimal
  - git
  - neofetch
  - net-tools
  - docker-ce (+ docker bundle packages)

Status: VM state matches configuration
```

Or if issues found:

```
VM Verification Results:
========================
Target: {{vm_ip}} ({{vm_hostname}})

✓ Hostname: Matches
✓ SSH Service: Enabled
✗ Packages (3/5 matched):

Missing packages:
  - neofetch (in config, not on VM)
  - docker-ce (in config, not on VM)

Status: VM state has discrepancies
```

## 7. Synchronization Options

If discrepancies found, ask user:

**Option A: Baseline (Update Config)**
- Update `autoinstall.yaml` to match current VM state
- Use this when VM is the source of truth

**Option B: Provision (Update VM)**
- Install missing packages on VM
- Use this when config is the source of truth

**Option C: Report Only**
- No changes, just document the differences

## 8. Synchronization Workflow

### If Option A (Baseline):
1. Edit `context/autoinstall.yaml` to remove packages not on VM
2. Run validate_config procedure to verify syntax
3. Commit changes to git
4. Update `change_log.md`

### If Option B (Provision):
1. For each missing package, run installation
   ```bash
   ssh {{vm_username}}@{{vm_ip}} "sudo apt install -y <package>"
   ```
2. For missing bundles, run the appropriate installation_bundles procedure
3. Re-run verification to confirm installation
4. Update `change_log.md`

### If Option C (Report Only):
- Document findings for user reference
- No changes made

## 9. Troubleshooting

### SSH Connection Failed
```bash
# Test SSH connectivity
ssh -v {{vm_username}}@{{vm_ip}}
```

Possible causes:
- VM not running
- Wrong IP address
- Firewall blocking port 22
- SSH credentials incorrect

### Permission Denied
- Verify password or SSH key
- Check user exists on VM
- Run procedures/ssh_key_auth if needed

### Package Check Shows Nothing
```bash
# More comprehensive package list
ssh {{vm_username}}@{{vm_ip}} "dpkg -l | grep -i <package-name>"
```

The package might be installed with a different name or version.
