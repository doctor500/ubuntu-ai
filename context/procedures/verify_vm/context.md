# VM Verification Context

## Overview
Verify the live Ubuntu VM state matches the desired configuration defined in `autoinstall.yaml`.

## Goal
Ensure the target VM's current state (hostname, packages, services) aligns with the configuration file. This enables baselining (update config to match VM) or provisioning (update VM to match config).

## Triggers
When should an AI agent invoke this procedure?
- User asks to "verify VM state" or "check VM configuration"
- Before provisioning new packages to baseline current state
- After installing packages to confirm they're present
- When troubleshooting configuration drift
- As part of regular maintenance/audit workflow

## Prerequisites
Required before running:
- `context/user_data.json` must exist with VM connection details (`vm_ip`, `vm_username`, `vm_hostname`)
- `context/autoinstall.yaml` must exist with desired configuration
- Network connectivity to target VM
- SSH access to target VM (password or key-based)
- Target VM must be running and accessible

## Logic
Step-by-step verification flow:
1. Load VM connection details from `context/user_data.json`
2. Test network connectivity with ping
3. SSH into VM to gather current state:
   - Hostname
   - OS version and release info
   - Installed packages (matching autoinstall.yaml list)
   - Service status (e.g., SSH server)
4. Compare VM state against `context/autoinstall.yaml`
5. Report discrepancies:
   - Missing packages
   - Incorrect hostname
   - Disabled services
6. Offer options:
   - **Baseline:** Update config to match VM (if VM is source of truth)
   - **Provision:** Update VM to match config (if config is source of truth)
   - **Report only:** Just show differences

## Related Files
- `context/user_data.json` - VM connection details (IP, username, hostname)
- `context/autoinstall.yaml` - Desired configuration state
- `procedures/init_user_data/` - Run if user_data.json missing
- `procedures/validate_config/` - Validate config before comparison
- `installation_bundles/*/context.md` - Check bundle-specific packages

## AI Agent Notes
- **Auto-run Safety:** SAFE for read-only verification; ASK for provisioning/baselining
- **User Interaction:** Always show comparison results; ask for action if differences found
- **Common Failures:**
  - SSH connection timeout → Check VM is running and network accessible
  - Permission denied → Verify SSH credentials in user_data.json
  - user_data.json missing → Run init_user_data procedure first
- **Edge Cases:**
  - VM state partially matches → Report each discrepancy clearly
  - Packages installed that aren't in config → Note as "additional packages"
  - Config has packages VM doesn't → Note as "missing packages"
- **Error Handling:**
  - If user_data.json missing, offer to initialize it
  - If VM unreachable, fail gracefully with clear error message
  - If autoinstall.yaml missing, suggest init_autoinstall procedure
