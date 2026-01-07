# Documentation Maintenance Context

## Overview
Keep `README.md` synchronized with project structure.

## Goal
Ensure documentation accurately reflects available procedures and bundles without manual updates.

## Triggers
- New procedure or bundle added
- Structure changes
- Documentation out of sync
- Pre-commit check

## Prerequisites
See common_patterns.md#standard-prerequisites

## Logic
1. **Scan directories:** List `context/procedures` and `installation_bundles`
2. **Read descriptions:** Extract from each `context.md`
3. **Update README:** Regenerate lists in relevant sections
4. **Verify:** Check links match folder names

## Related Files
- `README.md` - Target file
- `context/procedures/` - Source
- `context/installation_bundles/` - Source

## AI Agent Notes

**Safety:** ASK | Modifies README

**Interaction:** Confirm updates found

**Specific:**
- **Extraction:** Read first line or "Overview" section
- **Formatting:** Use list format `* **[name]**: [description]`
