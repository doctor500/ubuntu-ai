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
**Common:** See common_patterns.md#standard-prerequisites

**Specific:**
- `context/autoinstall.yaml` must exist (use init_autoinstall if missing)
- Python 3 and Git installed locally
- `.tools/subiquity` repository (cloned automatically if missing)

## Logic
Validation workflow:
1. Check if `autoinstall.yaml` exists
2. Check if validation tools set up (`.tools/subiquity`)
3. If not set up → Install dependencies, clone Subiquity, initialize
4. Generate JSON schema from Subiquity
5. Run validation script against `autoinstall.yaml`
6. Parse results: Exit 0 = success, Exit 1 = errors found
7. Report results and suggest corrections if needed

## Related Files
- `context/autoinstall.yaml` - Configuration being validated
- `context/autoinstall-schema.json` - Generated validation schema
- `.tools/subiquity/` - Canonical's validation tools (gitignored)
- `procedures/init_autoinstall/` - Creates autoinstall.yaml if missing

## AI Agent Notes
**Safety:** SAFE | Read-only validation, no file modifications

**User Interaction:** Auto-run after config changes, show results clearly

**Common Issues:** See common_patterns.md#file-not-found, #yaml-syntax-error, #network-timeout

**Procedure-Specific:**
- First-time setup requires internet (git clone ~1-2 min)
- System dependencies may need sudo password
- Validation typically takes 2-5 seconds
- Schema generation must run from specific directory
- If validation fails → Parse and display specific error messages with fixes

**Performance:** First run 1-2 min (setup), subsequent runs 2-5 sec
