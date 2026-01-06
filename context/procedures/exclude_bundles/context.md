# Bundle Exclusion Context

## Overview
Generate variant autoinstall configurations that exclude specific installation bundles and their packages.

## Goal
Create customized `autoinstall.yaml` variants for different deployment scenarios by excluding specified installation bundles (e.g., Docker, custom builds). This enables maintaining multiple VM configurations from a single base template without manual package list management.

## Triggers
When should an AI agent invoke this procedure?
- User requests a "minimal" or "lightweight" configuration
- Creating configuration for environments where certain bundles aren't needed
- Testing autoinstall without optional components
- Deploying to restricted environments (e.g., no containers allowed)
- Generating configs for different VM roles (web server vs database server)

## Prerequisites
Required before running:
- `context/autoinstall.yaml` must exist (master configuration)
- Installation bundle(s) to exclude must have proper `context.md` files
- Bundle `context.md` must list "Packages Installed"
- Understanding of which bundles can be safely excluded

## Logic
Step-by-step exclusion flow:
1. User specifies bundle(s) to exclude (e.g., "docker")
2. For each excluded bundle:
   a. Read `context/installation_bundles/<bundle>/context.md`
   b. Extract "Packages Installed" list
   c. Identify bundle-specific `apt: sources` (check comments in autoinstall.yaml)
3. Load main `context/autoinstall.yaml` into memory
4. Remove identified packages from `packages:` list
5. Remove identified `apt: sources` entries (if exclusive to excluded bundles)
6. Remove bundle-specific configuration sections
7. Write modified configuration to `autoinstall-<variant>.yaml`
8. Validate new configuration with validate_config procedure
9. Report changes made and packages removed

## Related Files
- `context/autoinstall.yaml` - Master configuration (source)
- `context/autoinstall-<variant>.yaml` - Generated variant (output)
- `installation_bundles/*/context.md` - Bundle package lists
- `procedures/validate_config/` - Validate generated variant
- `installation_bundles/README.md` - Bundle structure documentation

## AI Agent Notes
- **Auto-run Safety:** SAFE - Generates new file, doesn't modify original
- **User Interaction:**
  - Confirm which bundles to exclude
  - Show packages that will be removed
  - Ask for variant name (e.g., "minimal", "no-docker")
  - Offer to validate generated config
- **Common Failures:**
  - Bundle context.md missing "Packages Installed" section → Warn user
  - Bundle not found in installation_bundles/ → List available bundles
  - Invalid YAML after exclusion → Run validation, show errors
- **Edge Cases:**
  - Excluding bundle that others depend on → Check dependencies, warn user
  - Package appears in multiple bundles → Only remove if all bundles excluded
  - apt: source used by multiple bundles → Keep if any bundle remains
  - Comment format in autoinstall.yaml doesn't match expected → Manual intervention needed
- **Error Handling:**
  - If can't parse autoinstall.yaml, suggest validation first
  - If bundle context.md malformed, skip that bundle with warning
  - If output file exists, ask to overwrite
- **Validation:** Always offer to run validate_config on generated file
- **Documentation:** Suggest adding comment to variant file explaining exclusions
