# Late-Command Addition to Autoinstall Context

## Overview
Add late-command scripts to autoinstall.yaml for post-installation automation during VM provisioning.

## Goal
Enable users to add custom scripts and commands to the autoinstall configuration's `late-commands` section. These commands execute after the base system is installed but before the first boot, allowing for system customization, additional software installation, configuration changes, and automation tasks that can't be handled by the standard autoinstall sections.

## Triggers
When should an AI agent invoke this procedure?

**Explicit Mode (Start Immediately):**
- User says "add this to autoinstall"
- User requests "include in autoinstall configuration"
- User explicitly mentions "late-command"

**Informational Mode (Suggest Only - No Auto-Start):**
- User executes script WITHOUT mentioning autoinstall
- User runs commands manually on VM
- User performs configuration changes
- **Action:** Inform user this can be added to autoinstall (optional)
- **Rule:** Do NOT ask for confirmation to start procedure
- **Exception:** Only start if user explicitly says "yes, add it"

**Script Builder Mode:**
- User knows goal but not specific script
- User asks "how do I automate [task]"
- User requests help creating automation script

## Prerequisites
**Common:** See common_patterns.md#standard-prerequisites

**Specific:**
- `context/autoinstall.yaml` must exist (use init_autoinstall if missing)
- Script or command to be added (from user or script builder)
- **CRITICAL:** verify_script procedure must validate ALL scripts
- Understanding of what the script does
- Knowledge of any package dependencies

## Logic
Step-by-step workflow for adding late-commands:

**1. Trigger Detection**
```
IF user explicitly mentions "add to autoinstall" → START procedure
ELIF user executes script/command → INFORM (optional), WAIT for "yes"
ELIF user knows goal but not script → ACTIVATE script builder
```

**2. Script Acquisition**
- **User Provides:** Use provided script/command
- **Script Builder:** Gather requirements, analyze if maps to existing procedure or custom script needed, build with user, validate

**3. Security Validation (MANDATORY - verify_script)**
- Download/save script to temp location
- Run automated security analysis
- Check for: malicious commands, destructive operations, network exfiltration, privilege escalation
- Present findings to user, get explicit approval
- If DANGEROUS → RECOMMEND alternatives

**4. Dependency Analysis**
- Check if script requires packages (curl, jq, git, etc.)
- If packages needed → Add to autoinstall.yaml packages section with comment
- Example: "jq # Required for late-command: JSON parsing"

**5. Late-Command Addition**
- Load autoinstall.yaml
- Check if late-commands section exists → Create if missing
- Add command with: descriptive comment, proper escaping, error handling
- Format for YAML (use curtin in-target)
- Validate YAML syntax

**6. Validation & Documentation**
- Run validate_config procedure
- Update change_log.md
- Offer to create documentation if complex

## Related Files
- `context/autoinstall.yaml` - Target file for late-commands
- `procedures/verify_script/` - MANDATORY security validation
- `procedures/init_autoinstall/` - Initialize config if missing
- `procedures/validate_config/` - Validate after changes
- `autoinstall.example.yaml` - Template with examples
- `change_log.md` - Document additions

## AI Agent Notes

**Safety:** NEVER | Always requires user approval, MANDATORY script security validation

**Trigger Modes - Critical Distinction:**

*Mode 1 - Explicit:* User says "add to autoinstall" → Auto-start, validate, add

*Mode 2 - Informational:* User runs command but doesn't mention autoinstall → After execution, inform: "ℹ️ This can be added to autoinstall (optional)" → Do NOT ask "would you like to?" → Only start if user says "yes"

*Mode 3 - Script Builder:* User has goal, no script → Gather requirements → Check existing procedures → Build custom if needed → Ask confirmation for exploratory

**Security Validation (CRITICAL):**

**ALWAYS use verify_script for ALL scripts - NO EXCEPTIONS**

Check for:
✅ Destructive commands (rm -rf, dd, mkfs)
✅ Data exfiltration (unauthorized uploads)
✅ Credential theft (reading unauthorized files)
✅ Malicious obfuscation (base64, hex)
✅ Unnecessary privilege escalation
✅ Backdoor installation

If ANY found → RECOMMEND ALTERNATIVES

**Dependency Management:**

Auto-detect common commands:
- curl/wget → Add curl or wget package
- jq → Add jq package  
- git → Add git package
- python3 scripts → Add python3-* packages

Add with comment: `curl  # Required for late-command: [description]`

**YAML Formatting:**

Simple: `- curtin in-target --target=/target -- command`

Multi-line:
```yaml
- |
  curtin in-target --target=/target -- bash -c '
  command1
  command2
  '
```

Escaping: Single quotes in doubles, escape $, add `|| true` for non-critical

**Common Issues:** See common_patterns.md#file-not-found, #yaml-syntax-error, #permission-denied

**Procedure-Specific:**
- Command fails during install → Check /var/log/installer/subiquity-curtin-install.log
- Package not installed → Add to packages section first
- Script timeout → Split into smaller commands
- YAML syntax → Check indentation, quotes, escaping

**Alternatives to Late-Commands:**
- cloud-init user-data (better for cloud)
- Package installation (use packages section)
- Snap packages (use snaps section)
- Installation bundles (create new bundle)
- Post-install scripts (run after first boot)

Use late-commands when:
- System configuration changes needed
- Enabling/disabling services
- One-time setup tasks
- Can't be done via packages/snaps

**Integration with Other Procedures:**
- verify_script → ALWAYS validate before adding
- validate_config → Check YAML after changes
- init_autoinstall → Create config if missing
- verify_vm → Test command execution after provision

**Example Workflow:** See procedure.md for 4 detailed examples

**Critical Reminders:**
1. Security validation is MANDATORY (no shortcuts)
2. Explicit vs Informational modes must be respected (don't over-prompt)
3. Keep security guidance inline (don't just reference)
4. Script builder should check existing procedures first
5. Default to declining execution for safety
