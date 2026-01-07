# Script Verification Context

## Overview
Verify and safely execute scripts from URLs or files with security analysis.

## Goal
Security validation before script execution. Detect malicious patterns, assess risk, require approval.

## Triggers
- ANY script execution from URL or unknown source
- Before adding scripts to late-commands
- User requests "run this script"
- **MANDATORY for add_late_command**

## Prerequisites
See common_patterns.md#standard-prerequisites, #security-considerations

**Specific:** Script location, user available for approval

## Logic
1. **Acquire script** (download URL or copy local to temp)
2. **Run security analysis** (pattern scan)
3. **Assess source trust** (official vs unknown)
4. **Calculate risk level** (SAFE/MEDIUM/HIGH/DANGEROUS)
5. **Present to user** with recommendations
6. **Execute if approved** with logging
7. **Audit trail** (log decision)

## Related Files
- `/tmp/script_analysis_*.log` - Temp analysis
- `procedures/add_late_command/` - Major consumer

## Security Patterns to Detect

| Category | Patterns |
|----------|----------|
| **Destructive** | rm -rf /, dd, mkfs, fdisk |
| **Exfiltration** | curl POST, wget uploads, nc shells |
| **Credential Theft** | /etc/shadow, ~/.ssh/, password files |
| **Obfuscation** | base64 -d, eval, hex encoding |
| **Privilege Escalation** | Unjustified sudo, SUID changes |
| **Backdoors** | SSH key injection, cron jobs, systemd services |

## Trust Levels

| Source | Trust | Action |
|--------|-------|--------|
| Official (docker, apt) | Higher | Still validate |
| Unknown domains | Low | High scrutiny |
| Shortened URLs | Dangerous | Decline |
| No HTTPS | Risk | Warn user |

## AI Agent Notes

**Safety:** NEVER | Always requires explicit approval

**Interaction:** Present clear analysis, default to declining

**Issues:** See common_patterns.md#network-timeout

**Specific:**
- Obfuscated → DECLINE, request readable version
- Multiple concerns → List all, recommend alternatives
- Unknown source → Explain risk, let user decide
- When in doubt → DECLINE

**Critical Rules:**
1. NEVER auto-approve based on source alone
2. ALWAYS run pattern analysis
3. ALWAYS require user approval
4. DEFAULT to declining when uncertain
