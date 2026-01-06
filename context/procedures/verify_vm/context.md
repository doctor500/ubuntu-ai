# VM Verification Context

## Overview
Verify live VM state matches expected autoinstall configuration.

## Goal
Compare actual VM state (packages, hostname, users, services) against configuration defined in `autoinstall.yaml`. Identifies drift between expected and actual state, enabling synchronization or baselining operations.

## Triggers
When should an AI agent invoke this procedure?
- After VM provisioning to confirm success
- User reports VM behaving unexpectedly
- Before making configuration changes (establish baseline)
- As part of VM compliance checking
- When documenting actual VM state

## Prerequisites
**Common:** See common_patterns.md#standard-prerequisites

**Specific:**
- `context/autoinstall.yaml` must exist (expected configuration)
- `context/user_data.json` must exist (VM connection details)
- SSH access to VM configured
- VM must be reachable and running

## Logic
Verification workflow:
1. Load expected config from autoinstall.yaml
2. Load VM connection details from user_data.json
3. Test VM connectivity (ping, SSH)
4. Gather VM state:
   - Hostname → compare with identity.hostname
   - Installed packages → compare with packages list
   - Running services → check critical services
   - Network config → verify accessibility
5. Compare expected vs actual
6. Report: matches, mismatches, missing, extra
7. Offer actions: baseline config to match VM, provision missing items, log drift

## Related Files
- `context/autoinstall.yaml` - Expected configuration
- `context/user_data.json` - VM connection details
- `procedures/ssh_key_auth/` - May be needed for access

## AI Agent Notes
**Safety:** SAFE | Read-only verification, no modifications

**User Interaction:** Show clear comparison table (expected vs actual)

**Common Issues:** See common_patterns.md#network-timeout, #permission-denied

**Procedure-Specific:**
- VM not reachable → Check IP in user_data.json, network connectivity
- SSH fails → May need ssh_key_auth procedure first
- Package version differences → Report but not necessarily error (updates normal)
- Extra packages → Normal (dependencies, auto-installed), document if significant

**Interpretation:**
- **Match:** VM provisioned correctly ✅
- **Mismatch:** Hostname wrong, missing packages → Provision issue
- **Extra packages:** Usually OK (dependencies), note if user-installed
- **Drift:** Expected after VM use, offer to baseline or re-provision

**Actions After Verification:**
- **Baseline:** Update autoinstall.yaml to match VM (document current state)
- **Provision:** Install missing packages on VM
- **Re-provision:** Start fresh if drift too large
- **Document:** Log findings for compliance/audit
