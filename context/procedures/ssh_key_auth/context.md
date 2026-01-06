# SSH Key Authentication Setup Context

## Overview
Transition VM authentication from password-based to SSH key-based for improved security and automation.

## Goal
Set up passwordless SSH authentication using public key cryptography, eliminating the need for manual password entry when connecting to the target VM. This improves security (keys are stronger than passwords) and enables automation (scripts can connect without interaction).

## Triggers
When should an AI agent invoke this procedure?
- User requests passwordless SSH access
- Setting up automated deployment workflows
- Frequent manual SSH connections become tedious
- Security policy requires key-based authentication
- After initial VM provisioning is complete
- When preparing for automated verification/provisioning scripts

## Prerequisites
Required before running:
- `openssh-server` installed and running on target VM
- `openssh-client` installed on local machine
- SSH public key exists locally (e.g., `~/.ssh/id_rsa.pub` or `~/.ssh/id_ed25519.pub`)
- Password access to VM (for initial key copy, one last time)
- `context/user_data.json` with VM connection details
- Network connectivity to target VM

## Logic
Step-by-step setup flow:
1. **Pre-flight Checks:**
   a. Verify SSH server active on VM: `ssh user@vm "systemctl is-active ssh"`
   b. Verify local SSH public key exists: `ls ~/.ssh/*.pub`
2. **User Interaction:**
   - Only proceed if both checks pass
   - Ask: "SSH key auth is possible. Enable as default?"
3. **Key Installation:**
   a. Copy public key to VM's `~/.ssh/authorized_keys`
   b. Use `ssh-copy-id` (preferred) or manual method
   c. Requires password input one last time
4. **Verification:**
   - Test connection without password: `ssh -o BatchMode=yes user@vm`
   - Confirm successful passwordless login
5. **Fallback:**
   - Standard SSH auto-falls back to password if key fails
   - Access is never lost

## Related Files
- `~/.ssh/id_rsa.pub` or `~/.ssh/id_ed25519.pub` - Local SSH public key
- `context/user_data.json` - VM connection details (IP, username)
- `procedures/verify_vm/` - Will benefit from passwordless access
- `procedures/init_user_data/` - Provides VM details needed here

## AI Agent Notes
- **Auto-run Safety:** ASK FIRST - Modifies VM auth config, needs approval
- **User Interaction:**
  - Show pre-flight check results
  - Explain benefits (security, automation, convenience)
  - Ask for password when running ssh-copy-id
  - Confirm success after verification
- **Common Failures:**
  - No local SSH key → Offer to generate with `ssh-keygen`
  - SSH server not running → Guide user to enable it
  - Permission denied during copy → Check VM password
  - Key copy succeeds but login still prompts → Check file permissions
- **Edge Cases:**
  - Multiple SSH keys available → Ask which to use
  - VM already has some authorized_keys → Append, don't overwrite
  - Different SSH port → Use `-p` flag with commands
  - Hostname/IP changed → Update user_data.json first
- **Error Handling:**
  - If ssh-copy-id unavailable, use manual method
  - If verification fails, don't panic - password auth still works
  - If connection times out, check network/firewall
- **Security Notes:**
  - Private key stays on local machine (never copy it)
  - Set proper permissions: `chmod 600 ~/.ssh/id_rsa`
  - Consider passphrase-protected keys for extra security
- **Post-Setup:** Password auth remains available as fallback unless explicitly disabled
