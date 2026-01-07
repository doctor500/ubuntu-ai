# Autoinstall Initialization Context

## Overview
Initialize `autoinstall.yaml` from template with customization.

## Goal
Create personalized configuration from `autoinstall.example.yaml` without exposing sensitive data in git.

## Triggers
- `autoinstall.yaml` missing
- User requests reset/init
- Dependency for other procedures

## Prerequisites
See common_patterns.md#standard-prerequisites

**Specific:** `autoinstall.example.yaml` exists

## Logic
1. **Check existence:** If present, ask before overwriting
2. **Copy template:** `cp autoinstall.example.yaml autoinstall.yaml`
3. **Customize:** Prompt for hostname, username, password (mkpasswd)
4. **Validate:** Run `validate_config`

## Related Files
- `autoinstall.example.yaml` - Template
- `autoinstall.yaml` - Output (gitignored)

## AI Agent Notes

**Safety:** SAME/ASK | Safe if missing, ASK if exists

**Interaction:** Prompt for customization values

**Issues:** See common_patterns.md#permission-denied

**Specific:**
- **Password:** Use `mkpasswd -m sha-512` (install `whois` if needed)
- **Secrets:** Warn user that this file contains sensitive hashes
