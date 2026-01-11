# Common Patterns Reference

Quick reference for shared patterns, prerequisites, and troubleshooting.

---

## Prerequisites

### Files Required
| File | Purpose | If Missing |
|------|---------|------------|
| `context/autoinstall.yaml` | Main config | Run `init_autoinstall` |
| `context/user_data.json` | VM connection | Run `init_user_data` |

### System Requirements
SSH client, Python 3, Git, network connectivity to VM

---

## Error Patterns

### File Not Found
```bash
ls -la context/                    # Check if exists
# Run init_autoinstall or init_user_data if missing
```

### Permission Denied
```bash
ls -ld context/                    # Check permissions
# Don't use sudo to create files
```

### Network/SSH Timeout
```bash
ping [vm-ip]                       # Check connectivity
ssh user@vm 'echo ok'              # Test SSH
# Update IP in user_data.json
```

### YAML Syntax Error
```bash
python3 -c "import yaml; yaml.safe_load(open('context/autoinstall.yaml'))"
# Run validate_config procedure
```

---

## Security Guidelines

| Topic | Rule |
|-------|------|
| Scripts | Use `verify_script` for ALL external scripts |
| Passwords | Never store plain-text; use `openssl passwd -6` for hashing |
| Sensitive files | Keep gitignored: autoinstall.yaml, user_data.json |
| Sudo | Only when required, always ask user approval |

---

## Safety Levels

| Level | When | Action |
|-------|------|--------|
| **SAFE** | Read-only, validation | Auto-run |
| **ASK** | Modifies config/state | Confirm first |
| **NEVER** | Security-sensitive | Explicit approval |

---

## Procedure Quick Reference

### Configuration
| Need | Procedure |
|------|-----------|
| Initialize config | `init_autoinstall` |
| Validate config | `validate_config` |
| Add late-command | `add_late_command` |
| Exclude bundles | `exclude_bundles` |

### VM Operations
| Need | Procedure |
|------|-----------|
| Setup VM connection | `init_user_data` |
| Verify VM state | `verify_vm` |
| Setup SSH keys | `ssh_key_auth` |
| E2E test | `e2e_autoinstall_test` |

### Security
| Need | Procedure |
|------|-----------|
| Execute script | `verify_script` (ALWAYS) |

---

## Autoinstall Key Learnings

### 2-Phase Desktop Installation
**Problem:** `ubuntu-desktop-minimal` breaks SSH password auth (GDM/PAM conflict).

**Solution:** Install on first boot via systemd service (integrated in `autoinstall.example.yaml`).

**Troubleshooting:**
```bash
systemctl status first-boot-phase2.service    # Check status
cat /var/log/phase2.log                        # View logs
sudo /usr/local/bin/first-boot-phase2.sh      # Re-run manually
sudo rm /var/lib/phase2-complete && sudo reboot  # Reset and retry
```

### Heredoc Limitation (CRITICAL)
Heredocs don't work in late-commands due to YAML→curtin→bash escaping.

```yaml
# ❌ WRONG
- curtin ... -- bash -c 'cat > /file << EOF
content
EOF'

# ✅ CORRECT
- curtin ... -- bash -c 'echo "line1" > /file'
- curtin ... -- bash -c 'echo "line2" >> /file'
```

### Password Hash Escaping
Use single-quoted heredoc to prevent `$` expansion:
```bash
cat > autoinstall.yaml << 'EOF'
password: "$6$salt$hash..."
EOF
```

### External Repositories
Add repos in `early-commands` (runs before `packages:`):
```yaml
early-commands:
  - curl -fsSL https://download.docker.com/.../gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  - echo "deb [signed-by=/etc/apt/keyrings/docker.gpg] ..." > /etc/apt/sources.list.d/docker.list
  - apt-get update
```

---

## Response Templates

### Success
```
✅ [Operation] completed
Changes: [list changes]
Next: [optional steps]
```

### Failure
```
❌ [Operation] failed
Issue: [description]
Fix: [solution]
```

### Security Warning
```
⚠️ SECURITY: [script/operation]
Risk: [level]
Concerns: [list]
Approve? (yes/no)
```

---

*Updated when common patterns emerge or change.*
