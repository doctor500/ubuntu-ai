# Autoinstall Initialization Context  

## Overview
Initialize `autoinstall.yaml` from the example template with user customization.

## Goal
Create personalized `context/autoinstall.yaml` file from `autoinstall.example.yaml` template. This file defines the Ubuntu Desktop automated installation configuration including hostname, users, packages, and system settings. Ensures users have a working configuration without exposing sensitive data in version control.

## Triggers
When should an AI agent invoke this procedure?
- `context/autoinstall.yaml` does not exist
- User explicitly requests "initialize autoinstall"
- Another procedure requires autoinstall.yaml but it's missing
- User wants to reset configuration to template defaults

## Prerequisites
**Common:** See common_patterns.md#standard-prerequisites, #user-availability

**Specific:**
- `autoinstall.example.yaml` must exist in repository root
- User must provide: hostname, username, password (will be hashed)
- Terminal supports interactive prompts

## Logic
Initialization workflow:
1. Check if `autoinstall.yaml` exists
2. If exists → Ask if user wants to overwrite (default: no)
3. Copy `autoinstall.example.yaml` to `context/autoinstall.yaml`
4. Interactive customization:
   - Prompt for hostname
   - Prompt for username
   - Prompt for password → Hash with mkpasswd
   - Update identity section in YAML
5. Validate configuration
6. Confirm successful creation

## Related Files
- `autoinstall.example.yaml` - Safe template with dummy data
- `context/autoinstall.yaml` - Generated personalized config (gitignored)
- `procedures/validate_config/` - Validates generated file

## AI Agent Notes
**Safety:** SAFE to copy template | ASK before overwrite | REQUIRES INPUT for customization

**User Prompting:**
- Show example format for each field
- Validate hostname format (no spaces, valid DNS)
- Hash password automatically (don't store plain-text)
- Confirm before overwriting existing file

**Common Issues:** See common_patterns.md#file-not-found, #permission-denied

**Procedure-Specific:**
- Template missing → Repository corruption, suggest re-clone
- mkpasswd not installed → Provide installation command
- User cancels mid-process → Don't create partial config
- File exists but corrupted → Offer backup then recreate

**Security:** Password is hashed before saving, file is gitignored by default
