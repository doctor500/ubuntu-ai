# User Data Initialization Context

## Overview
Initialize `user_data.json` with VM connection details (IP address, username, hostname).

## Goal
Create and populate the `context/user_data.json` file with environment-specific information that should not be hardcoded in procedures. This file stores personalized data like VM IP addresses, usernames, and hostnames, enabling procedures to work across different environments.

## Triggers
When should an AI agent invoke this procedure?
- `context/user_data.json` file does not exist
- AI agent encounters a placeholder (e.g., `{{vm_ip}}`) but the key is missing in the JSON
- User explicitly requests to update VM connection details
- Before running verify_vm procedure for the first time
- When setting up the project in a new environment

## Prerequisites
Required before running:
- None (this is typically the first procedure to run)
- User must know their VM details (IP, username, hostname)

## Logic
Step-by-step initialization flow:
1. Check if `context/user_data.json` exists
2. If exists, verify it has required keys
3. If missing or incomplete:
   a. Prompt user for required information:
      - `vm_ip`: IP address of the target VM
      - `vm_username`: SSH username for VM access
      - `vm_hostname`: Expected hostname of the VM
   b. Validate input (basic format checking)
   c. Create JSON file with provided values
4. Save file to `context/user_data.json`
5. Verify file was created successfully

## Related Files
- `context/user_data.json` - The file being created (gitignored)
- `procedures/verify_vm/` - Uses this data for VM connections
- `context/live_vm_verification.md` - References placeholders from this file
- `installation_bundles/docker/context.md` - Uses `{{vm_username}}` placeholder

## AI Agent Notes
- **Auto-run Safety:** REQUIRES USER INPUT - Cannot auto-run, must collect data
- **User Interaction:** Always prompt for VM details; show example format
- **Common Failures:**
  - User provides invalid IP format → Validate as xxx.xxx.xxx.xxx
  - User unsure of hostname → Suggest checking with `hostname` command on VM
  - File permissions issue → Ensure write access to context/ directory
- **Edge Cases:**
  - File exists but has old/incorrect data → Ask if user wants to update
  - Missing only some keys → Only prompt for missing values
  - User has multiple VMs → This file stores ONE VM's details; create variants if needed
- **Error Handling:**
  - If can't write file, check directory permissions
  - If user cancels, leave file as-is (or missing)
  - Validate IP format before saving
- **Security:** File is gitignored by design - contains potentially sensitive info
