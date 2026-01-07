# Bundle Exclusion Context

## Overview
Generate variant autoinstall configurations by excluding specific bundles.

## Goal
Create customized `autoinstall.yaml` variants (e.g., minimal, container-free) from a single base template without manual editing.

## Triggers
- User requests "minimal" or "lightweight" config
- Creating role-specific configurations
- Testing without optional components

## Prerequisites
See common_patterns.md#standard-prerequisites

**Specific:** `autoinstall.yaml` (master config)

## Logic
1. **Identify exclusions:** User selects bundles to remove (e.g., docker)
2. **Scan master config:** Find packages and late-commands owned by bundles
3. **Filter content:** Remove associated lines
4. **Generate variant:** Save as `autoinstall-<variant>.yaml`
5. **Validate:** Run `validate_config` on new file

## Related Files
- `autoinstall-minimal.yaml` - Typical output
- `installation_bundles/` - Source of package lists

## AI Agent Notes

**Safety:** SAFE | Creates new file, does not modify master

**Interaction:** Ask which bundles to exclude, suggest "minimal"

**Issues:** See common_patterns.md#file-not-found

**Specific:**
- Does NOT verify if exclusion breaks dependencies
- Use `diff` to show what was removed
