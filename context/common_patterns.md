# Common Patterns Reference

This document contains shared patterns, prerequisites, and troubleshooting guides referenced by multiple procedures across the project.

---

## Standard Prerequisites

### File Prerequisites
- **autoinstall.yaml:** Must exist in `context/autoinstall.yaml` (use `init_autoinstall` if missing)
- **user_data.json:** Required for VM operations in `context/user_data.json` (use `init_user_data` if missing)
- **Write permissions:** User must have write access to `context/` directory
- **Git repository:** Project must be Git-initialized with remote configured

### System Prerequisites
- **SSH access:** For VM operations, requires SSH client and network connectivity
- **Python 3:** For validation scripts (YAML parsing, JSON schema)
- **Git:** For version control operations
- **Terminal:** Interactive terminal for user input when required

### User Availability
- **Interactive input:** User must be available to answer prompts for configuration
- **Approval required:** User must explicitly approve security-sensitive operations
- **Password entry:** User may need to enter passwords for sudo operations

---

## Common Error Patterns

### File Not Found
**Error:** Configuration file or template missing

**Solutions:**
1. Check file path is correct (absolute paths recommended)
2. Verify file existence: `ls -la context/`
3. For autoinstall.yaml: Run `init_autoinstall` procedure
4. For user_data.json: Run `init_user_data` procedure
5. For repository files: May indicate repository corruption → re-clone

**Prevention:**
- Always check file existence before operations
- Use initialization procedures for missing config files

### Permission Denied
**Error:** Cannot write to file or directory

**Solutions:**
1. Check write permissions: `ls -ld context/`
2. Verify file ownership: `ls -l context/*.yaml`
3. Check if file is read-only: `ls -l [file]`
4. For gitignored files: Normal if not accessible (security feature)

**Prevention:**
- Ensure current user owns the repository
- Don't use sudo to create files (maintains ownership)

### Network Timeout
**Error:** SSH connection or download fails

**Solutions:**
1. Verify VM is reachable: `ping [vm-ip]`
2. Check SSH connectivity: `ssh user@vm 'echo connected'`
3. Verify network configuration in user_data.json
4. Check firewall rules
5. Try alternative network (WiFi vs Ethernet)

**Prevention:**
- Keep user_data.json updated with correct IP
- Test connectivity before batch operations

### YAML Syntax Error
**Error:** Invalid YAML in autoinstall.yaml

**Solutions:**
1. Check indentation (use 2 spaces, not tabs)
2. Verify quotes and escaping
3. Use YAML validator: `python3 -c "import yaml; yaml.safe_load(open('file'))"`
4. Run `validate_config` procedure for detailed analysis
5. Restore from backup if available: `context/autoinstall.yaml.backup-*`

**Prevention:**
- Use `validate_config` after every autoinstall.yaml change
- Keep backups (automatic in most procedures)
- Use proper escaping for special characters

### Git Conflict
**Error:** Cannot commit due to conflicts

**Solutions:**
1. Check git status: `git status`
2. Review uncommitted changes: `git diff`
3. Stash changes if needed: `git stash`
4. Pull latest: `git pull origin main`
5. Resolve conflicts and commit

**Prevention:**
- Commit frequently
- Pull before making changes
- Use feature branches for major work

### Command Not Found
**Error:** Required command missing

**Solutions:**
1. Check if package installed: `which [command]`
2. Install missing package: `sudo apt install [package]`
3. For VM: Verify package in autoinstall.yaml packages section
4. Check PATH: `echo $PATH`

**Prevention:**
- Document package dependencies in procedure prerequisites
- Add required packages to autoinstall.yaml

---

## Security Considerations

### Script Verification (CRITICAL)
**Always verify scripts before execution:**
- Use `verify_script` procedure for ALL external scripts
- Check for malicious patterns (credential theft, data exfiltration)
- Verify source authenticity
- Get explicit user approval
- Never auto-run unverified scripts

### Password Handling
**Secure password practices:**
- Never store plain-text passwords in files
- Use password hashing (mkpasswd for autoinstall)
- Prompt for passwords interactively (don't pass as arguments)
- Don't log or echo passwords
- Use key-based auth when possible (see `ssh_key_auth`)

### Configuration Sensitivity
**Protect sensitive files:**
- autoinstall.yaml → Contains hashed passwords, may contain keys
- user_data.json → Contains VM connection details
- change_log.md → May document security changes
- All gitignored by default (see `.gitignore`)
- Never commit unencrypted sensitive data

### VM Operations
**Safe VM interaction:**
- Verify VM identity before operations
- Use SSH keys for passwordless auth (see `ssh_key_auth`)
- Check command safety before execution on VM
- Avoid sudo unless absolutely necessary
- Validate VM state matches expectations (see `verify_vm`)

### Privilege Escalation
**Sudo usage guidelines:**
- Only use sudo when required
- Explain why sudo is needed
- Ask user approval for sudo commands
- Prefer non-privileged alternatives
- Document sudo requirements in procedure

---

## Pre-Execution Check Template

For procedures with external dependencies, add this section at the start of procedure.md:

```markdown
## Pre-Execution: Verify Procedure is Current

**Official Documentation:**
- [Tool Name]: [URL]

**Last Verified:** YYYY-MM-DD

**Versions Used:** (if applicable)
- [component]: [version]

**Quick Verification:**
```bash
# Check if key URL/resource is accessible
curl -I [key_url] 2>&1 | head -1
# Expected: HTTP/2 200
```

**If outdated:** [Action to take]
```

**When to include:** Procedures that depend on external URLs, install scripts, or versioned tools.

---

## AI Agent Notes Format

Standard format for context.md AI guidance:

```markdown
## AI Agent Notes

**Safety:** SAFE | ASK | NEVER
**Interaction:** [One-line guidance]
**Issues:** See common_patterns.md#[section]
**Specific:** [Procedure-specific notes only]
```

| Safety Level | Meaning | Action |
|--------------|---------|--------|
| SAFE | Read-only or safe creation | Auto-run |
| ASK | Modifies config/state | Confirm first |
| NEVER | Security-sensitive | Explicit approval |

See: common_patterns.md#standard-safety-levels for full details.

---

## Response Templates

### Missing File Template
```
ℹ️  [file] not found.

I'll create it using the [procedure] procedure.
You'll need to provide:
  - [requirement 1]
  - [requirement 2]

Proceed? (This is safe - creates new file, doesn't modify existing)
```

### File Exists Template
```
⚠️  [file] already exists.

Current configuration:
  [show relevant config]

Would you like to:
  1. Keep existing (recommended)
  2. Overwrite with new configuration
  3. Create backup and modify

Please confirm your choice.
```

### Security Warning Template
```
⚠️  SECURITY ANALYSIS REQUIRED

Script: [name/URL]
Risk Level: [SAFE/MEDIUM/HIGH/DANGEROUS]

Concerns found:
  - [concern 1]
  - [concern 2]

Recommendation: [alternative or approval needed]

Proceed only if you trust the source and understand the risks.
Approve? (yes/no)
```

### Validation Success Template
```
✅ Validation completed successfully

Checks performed:
  ✅ [check 1]
  ✅ [check 2]
  ✅ [check 3]

Configuration is valid and ready for use.
```

### Validation Failure Template
```
❌ Validation failed

Issues found:
  ❌ [issue 1]: [description]
     → Solution: [fix]
  
  ❌ [issue 2]: [description]
     → Solution: [fix]

Please fix these issues and run validation again.
```

### Operation Complete Template
```
✅ [Operation] completed successfully

Changes made:
  - [change 1]
  - [change 2]

Next steps:
  1. [optional step 1]
  2. [optional step 2]

[Additional notes if any]
```

---

## Standard Safety Levels

### SAFE - Auto-run Permitted
**Criteria:**
- Read-only operation OR
- Creates new file without modifying existing OR
- Validation/verification only

**Examples:**
- validate_config (read-only)
- verify_vm (read-only verification)
- File existence checks

**User Action:** Run automatically, show results

### ASK - Require Confirmation
**Criteria:**
- Modifies existing configuration OR
- Changes system state OR
- May have side effects

**Examples:**
- init_autoinstall (when file exists)
- maintain_docs (updates README)
- ssh_key_auth (modifies VM auth)

**User Action:** Show what will happen, ask approval

### NEVER - Always Require Explicit Approval
**Criteria:**
- Security-sensitive operations OR
- Irreversible changes OR
- External script execution

**Examples:**
- verify_script (executes external code)
- add_late_command (modifies autoinstall automation)
- Sudo operations on VM

**User Action:** Full explanation, explicit "yes" required, default to no

---

## Cross-Procedure Integration

### Dependency Chain
```
init_autoinstall → validate_config → add_late_command
                → exclude_bundles
                
init_user_data → verify_vm → ssh_key_auth

verify_script ← (used by ANY procedure executing code)
```

### When to Use Which Procedure

**Configuration Management:**
- Missing autoinstall.yaml → `init_autoinstall`
- Validate autoinstall.yaml → `validate_config`
- Add late commands → `add_late_command`
- Need variant config → `exclude_bundles`

**VM Operations:**
- Missing connection data → `init_user_data`
- Verify VM state → `verify_vm`
- Setup SSH keys → `ssh_key_auth`

**Security:**
- Execute any script → `verify_script` (ALWAYS)

**Documentation:**
- Update README → `maintain_docs`
- Update changelog → `init_change_log`

### Reference Format
**When referencing this document:**
```markdown
See: common_patterns.md#[section-anchor]

Examples:
- See: common_patterns.md#file-not-found
- See: common_patterns.md#security-considerations
- See: common_patterns.md#safe-auto-run-permitted
```

---

## Best Practices

### Documentation
- Keep procedure-specific details in procedure files
- Reference common patterns (don't duplicate)
- Update this file when adding universal patterns
- Cross-reference liberally

### Git Workflow
- Commit after each significant change
- Use descriptive commit messages
- Pull before push
- Keep sensitive files gitignored

### Testing
- Test procedures on pilot files first
- Validate after configuration changes
- Verify VM state after provisioning
- Keep backups of working configurations

### Maintenance
- Update common patterns as they emerge
- Remove obsolete patterns when no longer used
- Keep response templates current
- Review and update quarterly

---

**This reference is maintained alongside all procedures and should be updated when common patterns are identified or change.**
