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
**Common:** See common_patterns.md#user-availability

**Specific:**
- User must know their VM details (IP, username, hostname)
- This is typically the first procedure to run (no other dependencies)

## Logic
Initialization workflow:
1. Check if `context/user_data.json` exists
2. If exists, verify it has required keys
3. If missing or incomplete → Prompt for:
   - `vm_ip`: IP address of the target VM
   - `vm_username`: SSH username for VM access  
   - `vm_hostname`: Expected hostname of the VM
4. Validate input (basic format checking)
5. Create JSON file with provided values
6. Verify file was created successfully

## Related Files
- `context/user_data.json` - The file being created (gitignored)
- `procedures/verify_vm/` - Uses this data for VM connections
- `installation_bundles/docker/context.md` - Uses `{{vm_username}}` placeholder

## AI Agent Notes
**Safety:** NEVER | Requires interactive user input

**User Prompting:**
- Always show example format: `{"vm_ip": "10.1.21.29", ...}`
- Validate IP format (xxx.xxx.xxx.xxx) before saving
- Suggest using `hostname` command if user unsure of VM hostname

**Common Issues:**See common_patterns.md#file-not-found, #permission-denied

**Procedure-Specific:**
- File exists with old data → Ask if user wants to update
- Missing only some keys → Only prompt for missing values
- Multiple VMs → This stores ONE VM; create variants if needed

**Security:** File gitignored by design (contains sensitive connection details)
