# SSH Key Authentication Setup Context

## Goal
Transition the authentication method for the target VM from password-based to SSH key-based. This improves security and automation reliability by eliminating the need for manual password entry.

## Logic Flow
1.  **Pre-flight Checks (Automated):**
    *   **Remote:** Verify `openssh-server` is installed and active on the target VM.
    *   **Local:** Verify an SSH public key (e.g., `id_rsa.pub`, `id_ed25519.pub`) exists on the local machine.
2.  **User Interaction:**
    *   **Condition:** Only if *both* checks pass.
    *   **Action:** Propose the switch to the user: "SSH key auth is possible. Do you want to set it as the default?"
3.  **Execution:**
    *   Copy the public key to the VM's `~/.ssh/authorized_keys`.
4.  **Verification:**
    *   Test the connection without a password.
5.  **Fallback:**
    *   Standard SSH behavior automatically falls back to password if the key fails, ensuring access is not lost.

## Dependencies
- `openssh-client` (Local)
- `openssh-server` (Remote)
- `sshpass` (Optional, helpful for the initial copy step if non-interactive)
