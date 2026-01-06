# Script Verification Context

## Overview
Verify and safely execute scripts from URLs or local files with security analysis.

## Goal
Provide secure script execution with mandatory security validation. Analyze scripts for malicious patterns, assess risk levels, require user approval, and log execution for audit trail. Prevents execution of dangerous code while enabling legitimate automation.

## Triggers
When should an AI agent invoke this procedure?
- ANY script execution request from URL or unknown source
- Before adding scripts to autoinstall late-commands
- User requests "run this script"
- Downloading and executing installation scripts
- **MANDATORY for add_late_command procedure**

## Prerequisites
**Common:** See common_patterns.md#standard-prerequisites, #security-considerations

**Specific:**
- Script location (URL or local path)
- Understanding of script's intended purpose
- User available for approval decision
- Terminal for interactive prompts

## Logic
Verification workflow:

**1. Script Acquisition**
- If URL → Download to temp location
- If local → Copy to temp for analysis
- Never execute directly

**2. Security Analysis (Automated)**  
Scan for malicious patterns:
- Destructive commands: rm -rf /, dd, mkfs, fdisk
- Data exfiltration: curl/wget uploads, nc reverse shells
- Credential theft: /etc/shadow, /root/.ssh, password files
- Obfuscation: base64, hex encoding, eval, compressed payloads
- Privilege escalation: sudo without justification, setuid
- Backdoors: cron jobs, systemd services, SSH keys

**3. Source Trust Assessment**
- Official sources (apt.get, github.com/official) → Lower risk
- Unknown domains → Higher risk
- Shortened URLs → Dangerous
- No HTTPS → Risk
- Check domain reputation

**4. Risk Scoring**
- SAFE: Official source, no dangerous patterns, read-only operations
- MEDIUM: Some network activity, justified sudo, known source
- HIGH: Unknown source, privilege escalation, system modifications
- DANGEROUS: Malicious patterns, obfuscation, data theft detected

**5. User Approval**
- Present analysis results clearly
- Show risk level and specific concerns
- Recommend alternatives if available
- Require explicit "yes" for HIGH/DANGEROUS
- Default to declining for safety

**6. Execution (If Approved)**
- Log script content and decision
- Execute in controlled manner
- Monitor for unexpected behavior
- Capture output for review

**7. Audit Logging**
- Record: timestamp, script source, decision, user, analysis results
- Maintain execution history
- Enable security audits

## Related Files
- `/tmp/script_analysis_*.log` - Analysis results (temporary)
- `~/.script_exec_audit.log` - Execution history (permanent)
- `procedures/add_late_command/` - Major consumer of this procedure

## AI Agent Notes

**Safety:** NEVER | Security-critical, always requires explicit user approval

**Security Patterns to Detect:**

**Destructive Operations:**
- `rm -rf /`, `dd if=/dev/zero`, `mkfs`, `fdisk`, `cfdisk`
- File overwrites, mass deletions

**Network Exfiltration:**
- `curl -X POST`, `wget --post-data`, `nc` reverse shells
- Unauthorized data uploads

**Credential Theft:**
- Reading `/etc/shadow`, `/etc/passwd`, `~/.ssh/`
- Password prompts that shouldn't be there

**Obfuscation (RED FLAG):**
- Base64/hex encoding: `base64 -d`, `echo ... | sh`
- Compressed payloads: unexpected tar/gz pipes
- `eval` with variables

**Privilege Escalation:**
- Unjustified `sudo`
- SUID bit modifications
- Adding users to sudo group

**Backdoors:**
- SSH key injection
- Cron job creation without  disclosure
- Systemd service installation
- Port listeners

**Trust Assessment:**

**Trusted Sources:** (Lower risk but still validate)
- get.docker.com, apt.get official repos
- github.com/[verified-org]/[official-repo]
- Official vendor domains

**Untrusted Sources:** (Higher scrutiny)
- Personal domains, unknown sites
- Shortened URLs (t.co, bit.ly, etc.)
- No HTTPS
- Suspicious TLDs

**User Communication:**

Present results clearly:
```
Script Analysis Results:
Source: [URL/path]
Trust Level: [Official/Unknown/Suspicious]
Risk Level: [SAFE/MEDIUM/HIGH/DANGEROUS]

Concerns Found:
  ⚠️  [specific issue 1]
  ⚠️  [specific issue 2]

Recommendation: [Approve/Alternative/Decline]

Proceed? (yes/no, default: no)
```

**Common Issues:** See common_patterns.md#network-timeout, #permission-denied

**Procedure-Specific:**
- Script obfuscated → DECLINE, recommend asking source for readable version
- Multiple concerns → List all, recommend alternatives
- Safe but unknown source → Explain risk, let user decide
- Official but complex → Verify it's actually official (check domain)

**Default Stance:** When in doubt, decline. Security over convenience.

**Integration:**
- add_late_command → MUST use this for ALL scripts
- Any automation → Use this before execution
- Manual user scripts → Strongly recommend

**Critical Rules:**
1. NEVER auto-approve based on source alone
2. ALWAYS run pattern analysis
3. ALWAYS require user approval for execution
4. ALWAYS log decisions for audit
5. DEFAULT to declining when uncertain

**Performance:** Analysis typically 1-3 seconds, worth the wait for security
