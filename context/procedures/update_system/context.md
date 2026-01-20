# Update System Procedure Context

## Overview
Update system packages and installation bundles with version tracking.

## Goal
Keep VM software current while maintaining reproducible state via changelog.

## Triggers
- User requests package updates
- Security advisory published
- Bundle version outdated (pre-procedure check)
- Periodic maintenance (weekly/monthly)

## Prerequisites
See common_patterns.md#standard-prerequisites

**Specific:** VM accessible via SSH, user has sudo access

## Logic
1. **Connect:** SSH to target VM (from user_data.json)
2. **Scan:** Check available updates (APT + bundles)
3. **Report:** Show update summary, ask for approval
4. **Execute:** Apply approved updates
5. **Verify:** Confirm updated versions
6. **Track:**
   - Update `vm_update_log.md` (for package/service updates)
   - Update `change_log.md` (only if project structure changed)

## Related Files
- `user_data.json` - VM connection details
- `vm_update_log.md` - Package update log (gitignored)
- `change_log.md` - Project changelog (git tracked)
- `installation_bundles/*/procedure.md` - Version check commands

## AI Agent Notes

**Safety:** ASK | Modifies system state

**Interaction:**
| Step | Action |
|------|--------|
| Scan results | Show summary table |
| Before update | Ask: "Apply N updates?" |
| Held packages | Warn and explain |
| Bundle updates | Ask per-bundle or batch |

**Issues:** See common_patterns.md#network-timeout

**Specific:**
- Kubernetes packages are held (kubelet, kubeadm, kubectl) — skip unless explicit
- Homebrew updates run as user, APT as sudo
- Record package updates in `vm_update_log.md` (gitignored)
- Record project structure changes in `change_log.md` (tracked)
- Reboot required: kernel, systemd, glibc updates

## Update Scopes

| Scope | Command | Frequency |
|-------|---------|-----------|
| APT security | `apt upgrade` | Weekly |
| APT full | `apt full-upgrade` | Monthly |
| Homebrew | `brew upgrade` | Weekly |
| Bundles | Per-bundle verify | As needed |

## Version Tracking Format

```markdown
### Applied (VM System Update)
- **APT Packages Updated** (N packages):
  - `package-name` X.X.X → Y.Y.Y
- **Homebrew Packages Updated**:
  - `tool-name` X.X.X → Y.Y.Y
- **Cleaned Up** (N unused packages removed):
  - `package-name` (XX MB freed)
```
