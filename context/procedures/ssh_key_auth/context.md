# SSH Key Authentication Context

## Overview
Set up passwordless SSH key authentication between local machine and VM.

## Goal
Configure SSH public key authentication to enable secure, passwordless access to the target VM. This eliminates the need for password prompts during VM operations and procedures, improving automation and security.

## Triggers
When should an AI agent invoke this procedure?
- User requests "setup SSH keys" or "passwordless SSH"
- VM operations repeatedly prompt for password
- Before running automated procedures on VM
- Setting up new VM for first time

## Prerequisites  
**Common:** See common_patterns.md#standard-prerequisites, #user-availability

**Specific:**
- `context/user_data.json` must exist with VM connection details
- SSH client installed locally
- Initial password access to VM (for key upload)
- VM must have SSH server running

## Logic
SSH key setup workflow:
1. Check if SSH key pair exists locally (~/.ssh/id_rsa)
2. If missing → Generate new SSH key pair
3. Load VM details from user_data.json
4. Test current SSH access to VM
5. Copy public key to VM's authorized_keys:
   - Use ssh-copy-id if available
   - Or manually append to ~/.ssh/authorized_keys
6. Verify passwordless access works
7. Recommend disabling password auth on VM (security best practice)

## Related Files
- `context/user_data.json` - VM connection details
- `~/.ssh/id_rsa` - Private key (local)
- `~/.ssh/id_rsa.pub` - Public key (local)
- `~/.ssh/authorized_keys` - On VM (key destination)

## AI Agent Notes
**Safety:** ASK | Modifies VM authentication configuration

**User Interaction:**  
- Ask password once during key upload
- Confirm before modifying VM auth settings
- Recommend (but don't auto-apply) password auth disable

**Common Issues:** See common_patterns.md#permission-denied, #network-timeout

**Procedure-Specific:**
- SSH key already exists → Use existing, don't regenerate
- Key upload fails → Check VM SSH server status, firewall
- Permissions wrong → Fix with chmod 600 ~/.ssh/authorized_keys (on VM)
- Multiple keys → Add to existing authorized_keys, don't overwrite

**Security Best Practices:**
- Use strong key (RSA 4096 or Ed25519)
- Protect private key (chmod 600)
- Consider passphrase for private key
- After setup, disable password auth on VM
- Never share private key

**Post-Setup:** Test with: `ssh user@vm 'echo success'` (should not prompt)
