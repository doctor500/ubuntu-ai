# Passwordless Sudo Context

## Overview
Configure user for passwordless sudo access to eliminate password prompts during system administration.

## Goal
Enable the primary user to execute sudo commands without password prompts. This improves workflow efficiency, enables automation scripts, and reduces friction during installation procedures (like kubeadm setup).

## Triggers
When should an AI agent invoke this procedure?
- Before running installation procedures that require multiple sudo commands
- User requests "setup passwordless sudo"
- Setting up automation that needs sudo access
- User frustrated with repeated password prompts

## Prerequisites
**Common:** See common_patterns.md#standard-prerequisites

**Specific:**
- User must have sudo privileges (in sudo group)
- Initial password access (to run the setup command)
- Know the username to configure

## Logic
Setup workflow:
1. Verify user is in sudo group
2. Create sudoers.d drop-in file for the user
3. Set proper file permissions (440)
4. Verify passwordless sudo works
5. (Optional) Add to autoinstall.yaml for new VMs

## Security Considerations

**⚠️ Important Trade-offs:**

| Aspect | With Password | Without Password |
|--------|--------------|------------------|
| **Security** | Higher | Lower |
| **Convenience** | Lower | Higher |
| **Automation** | Harder | Easier |
| **Risk** | Unauthorized access blocked | Any session can sudo |

**Recommended Use Cases:**
- ✅ Development VMs
- ✅ Local testing environments
- ✅ Single-user workstations
- ❌ Production servers (use with caution)
- ❌ Shared systems

**Mitigation:**
- Keep SSH key authentication (no password SSH ok, but keys required)
- Lock session when away
- Ensure physical security of device

## Related Files
- `/etc/sudoers.d/90-nopasswd-{username}` - Created file
- `context/user_data.json` - Source of username
- `context/autoinstall.yaml` - Can include this in late-commands

## AI Agent Notes
**Safety:** ASK | Reduces system security, user must understand trade-off

**User Interaction:**
- Explain security implications
- Confirm user understands the trade-off
- Ask for username if not available from user_data.json

**Common Issues:** See common_patterns.md#permission-denied

**Procedure-Specific:**
- File permissions wrong → Must be 440, owned by root
- Syntax error in sudoers → Can lock out sudo, use visudo to test
- Wrong username → Double-check spelling
- User not in sudo group → Add user to sudo group first

**Autoinstall Integration:**
Place as FIRST late-command to enable passwordless sudo before other installations run.

**Verification:**
```bash
sudo -n true && echo "Passwordless sudo works!" || echo "Still requires password"
```
