# SSH Key Authentication Setup Procedure

## Pre-Execution: Verify Procedure is Current

**Official Documentation:**
- OpenSSH: https://www.openssh.com/manual.html
- Ubuntu SSH Guide: https://ubuntu.com/server/docs/openssh-server
- ssh-copy-id: https://www.ssh.com/academy/ssh/copy-id

**Last Verified:** 2026-01-05

**Note:** SSH key authentication is a stable, long-established standard. Changes are rare.

**Quick Verification:**
```bash
# Check ssh-copy-id is available
which ssh-copy-id
# Expected: /usr/bin/ssh-copy-id
```

**If outdated:** Check Ubuntu SSH documentation for any changes.

---

## 1. Automated Pre-flight Checks
Before prompting the user, verify the environment.

### A. Check Remote SSH Server
Verify the remote VM has `openssh-server` installed and active.
```bash
ssh <user>@<host> "systemctl is-active ssh"
# Expected Output: active
```

### B. Check Local Public Keys
Check for existing public keys.
```bash
ls ~/.ssh/*.pub
# Expected Output: One or more .pub files (e.g., /home/user/.ssh/id_rsa.pub)
```
*If no keys exist, the AI should prompt the user to generate one first using `ssh-keygen`.*

## 2. User Prompt
**If (A) and (B) are successful:**
Ask the user: *"I detected an SSH key on your local machine and the SSH server is active on the VM. Would you like to enable SSH key-based authentication for automatic login?"*

## 3. Execution (Install Key)
If the user accepts, install the key. Use `ssh-copy-id` for safety, or a manual method if that is unavailable.

**Method 1: ssh-copy-id (Preferred)**
```bash
# Requires password input one last time
ssh-copy-id -i ~/.ssh/<selected_key>.pub <user>@<host>
```

**Method 2: Manual (Fallback)**
```bash
cat ~/.ssh/<selected_key>.pub | ssh <user>@<host> "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
```

## 4. Verification
Verify that passwordless login works.
```bash
ssh -o BatchMode=yes -o PasswordAuthentication=no <user>@<host> "echo 'SSH Key Auth Success'"
```

## 5. Fallback Confirmation
If the verification fails, SSH clients default to password authentication (unless explicitly disabled in `ssh_config`). No specific rollback is needed for the client config, but the user should be informed that password auth will be used as a fallback.
