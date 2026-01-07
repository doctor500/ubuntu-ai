# Configuration Validation Context

## Overview
Validate `autoinstall.yaml` against Canonical's schema.

## Goal
Ensure syntax correctness to prevent installation failures.

## Triggers
- Modification of `autoinstall.yaml`
- Before provisioning or committing
- Debugging installation errors

## Prerequisites
See common_patterns.md#standard-prerequisites

**Specific:** Python 3, Git, access to `subiquity` repo

## Logic
1. **Setup:** Clone `subiquity` repo to `.tools/` if missing
2. **Schema:** Generate JSON schema from subiquity source
3. **Validate:** Run `validate-autoinstall-user-data.py`
4. **Report:** Success or specific syntax error

## Related Files
- `autoinstall.yaml` - Input
- `.tools/subiquity` - Validator tool source
- `autoinstall-schema.json` - Generated schema

## AI Agent Notes

**Safety:** SAFE | Read-only validation

**Interaction:** Report pass/fail status

**Issues:** See common_patterns.md#yaml-syntax-error

**Specific:**
- **Sudo:** Do NOT run validation as sudo (tool requirement)
- **Path:** Must run from within `.tools/subiquity` dir
