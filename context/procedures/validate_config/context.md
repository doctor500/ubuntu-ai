# Configuration Validation Context

## Overview
Validate `autoinstall.yaml` syntax and structure against Canonical's autoinstall schema.

## Goal
Ensure the autoinstall configuration file is syntactically correct and conforms to the official schema before using it for VM provisioning or validation. This prevents errors during installation and ensures compatibility with Ubuntu's Subiquity installer.

## Triggers
When should an AI agent invoke this procedure?
- After creating or modifying `autoinstall.yaml`
- Before provisioning a VM with the configuration
- After running init_autoinstall procedure
- Before committing changes to git
- When user reports installation errors
- As part of CI/CD validation pipeline

## Prerequisites
Required before running:
- `context/autoinstall.yaml` must exist
- Python 3 installed on local system
- Git installed on local system
- System dependencies for Subiquity validator installed
- `.tools/subiquity` repository cloned (or will be cloned automatically)

## Logic
Step-by-step validation flow:
1. Check if `autoinstall.yaml` exists
2. Check if validation tools are set up (`.tools/subiquity`)
3. If not set up:
   a. Install system dependencies (Python packages)
   b. Clone Subiquity repository
   c. Initialize Subiquity external dependencies
4. Generate JSON schema from Subiquity
5. Run validation script against `autoinstall.yaml`
6. Parse validation output:
   - Exit code 0 → Success
   - Exit code 1 → Validation errors found
7. Report results to user
8. If errors found, suggest corrections

## Related Files
- `context/autoinstall.yaml` - The configuration being validated
- `context/autoinstall-schema.json` - Generated validation schema
- `.tools/subiquity/` - Canonical's validation tools (gitignored)
- `procedures/init_autoinstall/` - Creates autoinstall.yaml if missing

## AI Agent Notes
- **Auto-run Safety:** SAFE - Validation is read-only, doesn't modify files
- **User Interaction:** Automatically run after config changes; show results
- **Common Failures:**
  - `autoinstall.yaml` missing → Run init_autoinstall first
  - Dependencies not installed → Offer to install them (requires sudo)
  - Subiquity tools not cloned → Auto-clone is safe
  - Validation errors → Show error details and suggest fixes
- **Edge Cases:**
  - First-time setup requires internet connection (git clone)
  - System dependency installation requires sudo password
  - Schema generation must run from specific directory
  - Validation script has path dependencies
- **Error Handling:**
  - If autoinstall.yaml missing, suggest init_autoinstall
  - If dependencies missing, provide installation commands
  - If validation fails, parse and display specific error messages
  - If network unavailable, note that Subiquity tools can't be downloaded
- **Performance:** Validation typically takes 2-5 seconds; first-time setup 1-2 minutes
