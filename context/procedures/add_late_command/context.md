# Late-Command Addition Context

## Overview
Add late-command scripts to autoinstall.yaml for post-installation automation.

## Goal
Add custom scripts to the `late-commands` section for post-install automation (system config, software install, service setup).

## Triggers
| Mode | Trigger | Action |
|------|---------|--------|
| **Explicit** | User says "add to autoinstall" | START immediately |
| **Informational** | User runs command manually | INFORM only, wait for "yes" |
| **Script Builder** | User asks "how to automate X" | Gather requirements, build |

## Prerequisites
See common_patterns.md#standard-prerequisites

**Specific:** autoinstall.yaml exists, verify_script for ALL scripts

## Logic
1. **Detect trigger mode** (Explicit/Informational/Builder)
2. **Get script** (user provides or build with user)
3. **Security validation** (MANDATORY - use verify_script)
4. **Check dependencies** (add packages if needed)
5. **Add to autoinstall.yaml** (format for YAML, validate)
6. **Document** (update changelog)

## Related Files
- `autoinstall.yaml` - Target file
- `procedures/verify_script/` - Security validation
- `procedures/validate_config/` - YAML validation

## AI Agent Notes

**Safety:** NEVER | Always requires approval + script verification

**Interaction:** Respect trigger modes - don't over-prompt on informational

**Issues:** See common_patterns.md#yaml-syntax-error, #permission-denied

**Specific:**
- **Security:** ALWAYS use verify_script - check for destructive commands, exfiltration, backdoors
- **Dependencies:** Auto-add packages (curl, jq, git) with comments
- **Format:** Use `curtin in-target --target=/target -- command`
- **Multi-line:** Use `- |` with proper escaping
- **Failure logs:** /var/log/installer/subiquity-curtin-install.log
- **Examples:** See procedure.md for detailed examples
