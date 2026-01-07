# SSH Key Authentication Context

## Overview
Set up passwordless SSH key authentication.

## Goal
Enable secure, passwordless access to VM for ease of automation.

## Triggers
- User requests "setup SSH keys"
- Frequent password prompts
- Preparing for automation

## Prerequisites
See common_patterns.md#standard-prerequisites

**Specific:** `user_data.json` exists

## Logic
1. **Check remote:** Verify `openssh-server` active
2. **Check local:** Look for existing keys (`~/.ssh/*.pub`)
3. **Prompt:** Ask to install key
4. **Install:** Use `ssh-copy-id` (preferred) or manual append
5. **Verify:** Test without password

## Related Files
- `~/.ssh/` - Local keys
- `~/.ssh/authorized_keys` - Remote file

## AI Agent Notes

**Safety:** ASK | Modifies remote auth

**Interaction:** Confirm before installing key

**Issues:** See common_patterns.md#permission-denied, #network-timeout

**Specific:**
- **Key Gen:** If no local key, offer to generate `ssh-keygen`
- **Fallback:** If `ssh-copy-id` missing, append manually
