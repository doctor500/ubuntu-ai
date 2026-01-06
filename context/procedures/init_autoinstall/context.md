# Autoinstall Configuration Initialization Context

## Overview
Initialize `autoinstall.yaml` from the template when the personalized config file is missing.

## Goal
Ensure the `autoinstall.yaml` file exists before attempting to validate, modify, or sync it with a VM. This procedure creates a working configuration file from `autoinstall.example.yaml` when needed, preventing errors and enabling proper configuration management.

## Triggers
When should an AI agent invoke this procedure?
- AI agent prepares to validate or modify config but detects `autoinstall.yaml` is missing
- New clone of the repository (fresh installation)
- User accidentally deletes or moves `autoinstall.yaml`
- Before any operation that requires reading `context/autoinstall.yaml`
- As first step when setting up a new environment

## Prerequisites
Required before running:
- `context/autoinstall.example.yaml` must exist (template file in repository)
- Write permissions to `context/` directory
- User must be available to provide customization details (or accept template defaults)

## Logic
Step-by-step initialization flow:
1. Check if `context/autoinstall.yaml` exists
2. If exists:
   - Verify it's not corrupted (basic YAML syntax check)
   - Proceed with original operation
3. If missing:
   a. Copy from `context/autoinstall.example.yaml`
   b. Warn user that template values MUST be customized
   c. Offer customization options:
      - **Interactive:** Prompt for hostname, username, generate password hash
      - **Manual:** User will edit file themselves later
      - **Template:** Use as-is for testing (not production)
4. If interactive chosen:
   a. Prompt for hostname
   b. Prompt for username
   c. Prompt for password (will be hashed with mkpasswd)
   d. Update file with user-provided values
5. Confirm file created successfully
6. Suggest next steps (validation, verification)

## Related Files
- `context/autoinstall.example.yaml` - Source template (safe, in git)
- `context/autoinstall.yaml` - Target file (gitignored, personalized)
- `procedures/validate_config/` - Should run after initialization
- `procedures/verify_vm/` - Uses this config for comparison
- `README.md` - Documents the initialization workflow

## AI Agent Notes
- **Auto-run Safety:** SAFE to copy template; REQUIRES INPUT for customization
- **User Interaction:** 
  - Always display warning about customization requirement
  - Offer three paths: Interactive, Manual, or Template-only
  - For interactive, validate inputs (hostname format, password strength)
- **Common Failures:**
  - Template file missing → Repository corruption, suggest re-clone
  - Permission denied → Check write access to context/ directory
  - mkpasswd not installed → Guide user to install whois package
- **Edge Cases:**
  - File exists but is empty → Treat as missing, recreate
  - File exists but YAML invalid → Offer to backup and recreate
  - User provides weak password → Warn but allow (their choice)
  - Multiple customization attempts → Don't overwrite previous work
- **Error Handling:**
  - If copy fails, check disk space and permissions
  - If mkpasswd unavailable, show manual hash generation method
  - If user cancels, leave template copy as-is with warnings
- **Security:** Remind user that autoinstall.yaml is gitignored for security
- **Best Practice:** Always run validate_config after initialization
