# Late-Command Addition to Autoinstall Context

## Overview
Add late-command scripts to autoinstall.yaml for post-installation automation during VM provisioning.

## Goal
Enable users to add custom scripts and commands to the autoinstall configuration's `late-commands` section. These commands execute after the base system is installed but before the first boot, allowing for system customization, additional software installation, configuration changes, and automation tasks that can't be handled by the standard autoinstall sections.

## Triggers
When should an AI agent invoke this procedure?

### Explicit Triggers (Start Procedure):
- User explicitly asks to "add this to autoinstall"
- User says "include this script in autoinstall configuration"
- User requests "make this part of VM provisioning"
- User says "add late-command for [task]"

### Informational Triggers (Inform Only, No Auto-Start):
- User executes a script WITHOUT mentioning autoinstall
- User runs commands manually on VM
- User performs configuration changes
- **Action:** Inform user this can be added to autoinstall (optional)
- **Rule:** Do NOT ask for confirmation to start procedure
- **Exception:** Only start if user explicitly says "yes, add it"

### Script Builder Triggers:
- User knows the goal but not the specific script
- User asks "how do I automate [task]"
- User requests help creating automation script

## Prerequisites
Required before running:
- `context/autoinstall.yaml` must exist (use init_autoinstall if missing)
- Script or command to be added (from user or script builder)
- **CRITICAL:** verify_script procedure must validate ALL scripts
- Understanding of what the script does
- Knowledge of any package dependencies

## Logic
Step-by-step workflow for adding late-commands:

### 1. Trigger Detection
```
IF user explicitly mentions "add to autoinstall":
    START procedure
ELIF user executes script/command:
    INFORM: "This can be added to autoinstall (optional)"
    WAIT for user response
    IF user says "yes":
        START procedure
    ELSE:
        Do not proceed
```

### 2. Script Acquisition
**Option A: User Provides Script**
- User provides complete script or command
- Proceed to security validation

**Option B: Script Builder (User Knows Goal)**
```
IF user knows goal but not script:
    GATHER requirements:
        - What is the end goal?
        - What needs to be configured?
        - Any specific tools/packages needed?
    
    ANALYZE if requirement maps to:
        - Custom script → Use this procedure
        - Another autoinstall section → Check for existing procedure
        - Existing procedure available → Redirect to that procedure
        - No existing procedure → Propose exploratory approach
        - ASK user confirmation before exploratory approach
```

### 3. Security Validation (MANDATORY)
```
ALWAYS use verify_script procedure:
    1. Download/save script to temp location
    2. Run security analysis (verify_script)
    3. Check for:
        - Malicious commands
        - Destructive operations
        - Network exfiltration
        - Privilege escalation
    4. Present findings to user
    5. Get explicit user approval
    6. If DANGEROUS → RECOMMEND alternatives
    7. If approved → Proceed
```

### 4. Dependency Analysis
```
CHECK if script requires packages:
    IF packages needed:
        LIST required packages
        ADD to autoinstall.yaml packages section
        ADD comment: "# Required for late-command: [description]"
    ELSE:
        Proceed without package additions
```

### 5. Late-Command Addition
```
1. Load autoinstall.yaml
2. Check if late-commands section exists
3. IF not exists:
       CREATE late-commands section
4. ADD new command with:
    - Descriptive comment
    - Proper escaping
    - Error handling (|| true if non-critical)
5. Format properly for YAML
6. Validate YAML syntax
```

### 6. Validation
```
1. Run validate_config procedure
2. Check YAML is valid
3. Verify command syntax
4. Test command logic if possible
```

### 7. Documentation
```
1. Add comment in autoinstall.yaml explaining command
2. Update change_log.md
3. Offer to create documentation file if complex
```

## Related Files
- `context/autoinstall.yaml` - Target file for late-commands
- `procedures/verify_script/` - MANDATORY security validation
- `procedures/init_autoinstall/` - Initialize config if missing
- `procedures/validate_config/` - Validate after changes
- `autoinstall.example.yaml` - Template with late-commands examples
- `change_log.md` - Document additions

## AI Agent Notes

### Auto-run Safety
- **NEVER AUTO-RUN** - Always requires user approval
- **Script validation MANDATORY** - Use verify_script without exception
- **Inform vs Execute:** Know when to suggest vs when to execute

### User Interaction Patterns

**Pattern 1: Explicit Request**
```
User: "Add this script to autoinstall late-commands"
→ START procedure immediately
→ Validate script with verify_script
→ Show analysis
→ Get approval
→ Add to config
```

**Pattern 2: Implicit Action (Inform Only)**
```
User: "Run this command on the VM" (no mention of autoinstall)
→ Execute the command
→ After completion: "ℹ️ This can be added to autoinstall for future VMs (optional)"
→ Do NOT ask "Would you like me to add it?"
→ WAIT for user to explicitly say "yes" or "add it"
→ If user says yes: START procedure
→ If user ignores: Do nothing
```

**Pattern 3: Script Builder**
```
User: "I want to configure X but don't know the script"
→ ASK: "What is the desired end state?"
→ ASK: "Any specific requirements?"
→ ANALYZE: Does this map to existing procedure?
→ IF yes: "We have [procedure] that handles this"
→ IF no: "I can help build a custom script"
→ BUILD script with user input
→ VALIDATE with verify_script
→ ADD via this procedure
```

### Security Validation (CRITICAL)

**ALWAYS use verify_script for:**
- User-provided scripts
- AI-generated scripts  
- Scripts from tutorials/Stack Overflow
- Commands with sudo
- ANY executable code

**Security Checklist:**
```
□ Script passed verify_script analysis
□ No destructive commands (rm -rf, dd, mkfs)
□ No credential theft attempts
□ No network exfiltration
□ Privilege escalation justified
□ User approved after seeing risks
□ Error handling included
```

### Package Dependency Handling

**Check for package requirements:**
```bash
# Example: Script uses 'jq' for JSON parsing
→ Check if jq in packages list
→ If not: Add "jq # Required for late-command: X"
→ Place near other related packages
```

**Common dependencies to check:**
- `curl`, `wget` - Network downloads
- `jq` - JSON parsing
- `python3-*` - Python dependencies
- `git` - Repository cloning
- Build tools - `gcc`, `make`, `build-essential`

### YAML Formatting Rules

**Late-commands section structure:**
```yaml
late-commands:
  # Always use list format
  - curtin in-target --target=/target -- command1
  - curtin in-target --target=/target -- command2
  
  # For complex scripts, use multiline:
  - |
    curtin in-target --target=/target -- bash -c '
    # Multi-line script here
    command1
    command2
    '
```

**Escaping rules:**
- Single quotes inside double quotes
- Escape special characters: `$`, `` ` ``, `\`
- Use `||  true` for non-critical commands
- Use curtin in-target for chroot execution

### Common Patterns

**Pattern A: Simple Command**
```yaml
late-commands:
  - curtin in-target --target=/target -- systemctl enable myservice
```

**Pattern B: With Package Dependency**
```yaml
packages:
  - nginx  # Required for late-command: web server setup

late-commands:
  - curtin in-target --target=/target -- systemctl enable nginx
```

**Pattern C: Multi-step Script**
```yaml
late-commands:
  - |
    curtin in-target --target=/target -- bash -c '
    mkdir -p /opt/myapp
    curl -o /opt/myapp/config.json https://example.com/config.json
    chmod 644 /opt/myapp/config.json
    '
```

### Error Handling

**Common failures:**
- YAML syntax error → Run validate_config
- Command fails during install → Add `|| true` if non-critical
- Package not available → Check package name, add to packages
- Script timeout → Split into smaller commands
- Permission denied → Use curtin in-target

**Troubleshooting:**
```
If late-command fails during install:
1. Check /var/log/installer/subiquity-curtin-install.log
2. Verify package dependencies installed
3. Test command manually on VM
4. Check escaping and quoting
5. Validate with validate_config
```

### Alternatives to Late-Commands

**Before using late-commands, consider:**
- **cloud-init user-data** - Better for cloud instances
- **Package installation** - Use autoinstall packages section
- **Snap packages** - Use autoinstall snaps section
- **Installation bundles** - Create new bundle for complex setups
- **Post-install scripts** - Run after first boot instead

**When late-commands is appropriate:**
- System configuration changes
- Enabling/disabling services
- Creating directories/files
- One-time setup tasks
- Can't be done via packages/snaps

### Best Practices

1. **Keep it simple** - One command per line when possible
2. **Add comments** - Explain what each command does
3. **Test first** - Run command manually before adding
4. **Use idempotent commands** - Safe to run multiple times
5. **Handle errors** - Use `|| true` for non-critical
6. **Document** - Update change_log.md
7. **Validate** - Always run validate_config after

### Example Workflow

```
User: "Add a command to enable Docker service at boot"

AI Agent:
1. ✅ Detect: Explicit request
2. ✅ Use verify_script: "systemctl enable docker"
3. ✅ Check dependencies: Docker package (already in config)
4. ✅ Security: Low risk (standard systemctl command)
5. ✅ Add to autoinstall.yaml:
   late-commands:
     - curtin in-target --target=/target -- systemctl enable docker
6. ✅ Validate config
7. ✅ Update change_log.md
8. ✅ Confirm to user
```

### Response Templates

**For Informational (Pattern 2):**
```
ℹ️  This command can be added to autoinstall.yaml for automatic 
execution during future VM provisioning. This would make it part 
of the base installation.

Would you like to add it as a late-command?
```

**For Security Concerns:**
```
⚠️  Security Analysis Results:
- Risk Level: [SAFE/MEDIUM/HIGH/DANGEROUS]
- Concerns Found: [list]
- Recommendation: [suggestion]

This command [will/will not] be added to autoinstall without 
additional review.

Proceed? (yes/no)
```

**For Dependency Additions:**
```
📦 Package Dependencies Detected:
- [package1] - [reason]
- [package2] - [reason]

I'll add these to the packages section with explanatory comments.
```

### Integration with Other Procedures

- **verify_script** - ALWAYS validate before adding
- **validate_config** - Check YAML after changes
- **init_autoinstall** - Create config if missing
- **exclude_bundles** - May affect late-commands
- **maintain_docs** - Update README if needed
