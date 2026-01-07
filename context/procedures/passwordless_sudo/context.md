# Passwordless Sudo Context

## Overview
Configure user for passwordless sudo access.

## Goal
Enable sudo without password prompts for workflow efficiency and automation.

## Triggers
- Before installation procedures with multiple sudo commands
- User requests passwordless sudo
- Setting up automation requiring sudo

## Prerequisites
See common_patterns.md#standard-prerequisites

**Specific:** User in sudo group, initial password access

## Logic
1. Verify user in sudo group
2. Create `/etc/sudoers.d/90-nopasswd-{username}`
3. Set permissions 440
4. Verify with `sudo -n true`
5. (Optional) Add to autoinstall.yaml

## Security Trade-offs

| Aspect | With Password | Without |
|--------|--------------|---------|
| Security | Higher | Lower |
| Convenience | Lower | Higher |
| Automation | Harder | Easier |

**Recommended:** ✅ Dev VMs, local testing | ❌ Production, shared systems

## Related Files
- `/etc/sudoers.d/90-nopasswd-{username}` - Created file
- `autoinstall.yaml` - Include as FIRST late-command

## AI Agent Notes

**Safety:** ASK | Reduces security, explain trade-off

**Interaction:** Explain implications, confirm understanding

**Issues:** See common_patterns.md#permission-denied

**Specific:**
- Permissions must be 440, owned by root
- Syntax error → Use visudo to test
- Must be FIRST late-command in autoinstall
- Verify: `sudo -n true && echo "Works!"`
