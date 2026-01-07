# VM Verification Context

## Overview
Compare live VM state with `autoinstall.yaml` configuration.

## Goal
Identify drift between defined config and actual VM state.

## Triggers
- Post-provisioning check
- Troubleshooting unexpected behavior
- Baselining before changes

## Prerequisites
See common_patterns.md#standard-prerequisites

**Specific:** VM accessible via SSH

## Logic
1. **Load config:** Read `autoinstall.yaml`
2. **Inspect VM:** SSH commands to check packages, hostname, users
3. **Compare:** Match config vs reality
4. **Report:** List missing items or differences

## Related Files
- `autoinstall.yaml` - Expected state
- `user_data.json` - Connection details

## AI Agent Notes

**Safety:** SAFE | Read-only inspection

**Interaction:** Reporting findings (Match/Drift)

**Issues:** See common_patterns.md#network-timeout

**Specific:**
- **Drift:** Common if manual changes made
- **Fix:** Does NOT auto-fix; recommends manual sync or late-commands
