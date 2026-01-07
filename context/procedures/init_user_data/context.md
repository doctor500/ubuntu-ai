# User Data Initialization Context

## Overview
Initialize `user_data.json` with VM connection details.

## Goal
Store environment-specific data (IP, user) separate from code to enable portable procedures.

## Triggers
- `user_data.json` missing
- Missing key encountered (e.g., `{{vm_ip}}`)
- User updates VM details
- New environment setup

## Prerequisites
See common_patterns.md#standard-prerequisites

## Logic
1. **Prompt user:** Get IP, Username, Hostname
2. **Create JSON:** Save to `context/user_data.json`
3. **Verify:** Check if SSH connects (optional)

## Related Files
- `user_data.json` - Target file (gitignored)

## AI Agent Notes

**Safety:** SAFE/ASK | Safe if missing

**Interaction:** Ask for connection details

**Issues:** See common_patterns.md#network-timeout

**Specific:**
- **Validation:** Ensure IP is valid format
- **Updates:** Can merge with existing keys if file exists
