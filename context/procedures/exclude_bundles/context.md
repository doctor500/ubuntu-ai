# Bundle Exclusion Context

## Overview
Generate variant autoinstall configurations that exclude specific installation bundles and their packages.

## Goal
Create customized `autoinstall.yaml` variants for different deployment scenarios by excluding specified installation bundles (e.g., Docker, custom builds). This enables maintaining multiple VM configurations from a single base template without manual package list management.

## Triggers
When should an AI agent invoke this procedure?
- User requests "minimal" or "lightweight" configuration
- Creating configuration for specific environments (container-free, restricted, etc.)
- Testing autoinstall without optional components
- Generating configs for different VM roles

## Prerequisites
**Common:** See common_patterns.md#standard-prerequisites

**Specific:**
- `context/autoinstall.yaml` must exist (master configuration)
- Installation bundle(s) to exclude must have `context.md` files
- Bundle `context.md` must list "Packages Installed"
- Understanding of which bundles can be safely excluded

## Logic
Exclusion workflow:
1. User specifies bundle(s) to exclude (e.g., "docker")
2. For each bundle → Read bundle context.md → Extract package list
3. Identify bundle-specific apt sources (check comments in autoinstall.yaml)
4. Load master autoinstall.yaml
5. Remove: Bundle packages, apt sources, related configurations
6. Generate variant filename (e.g., autoinstall-no-docker.yaml)
7. Validate variant configuration
8. Save to designated location

## Related Files
- `context/autoinstall.yaml` - Master configuration
- `context/installation_bundles/*/context.md` - Bundle definitions
- Generated variants: `autoinstall-no-{bundle}.yaml`

## AI Agent Notes
**Safety:** SAFE | Generates new file, doesn't modify original

**User Interaction:** Confirm bundle exclusion list, show package count being removed

**Common Issues:** See common_patterns.md#file-not-found

**Procedure-Specific:**
- Bundle context missing packages list → Can't auto-exclude, ask user for manual list
- Circular dependencies → Warn if removing package needed by remaining bundles
- Multiple bundle exclusion → Process in order, check for conflicts
- Variant naming → Use descriptive names (autoinstall-minimal.yaml vs autoinstall-no-docker-no-build.yaml)

**Validation:** Always run validate_config on generated variant before use
