# Documentation Maintenance Context

## Overview
Keep `README.md` synchronized with actual project structure and procedures.

## Goal
Automatically update project README to reflect current state: available procedures, file structure, installation bundles. Ensures documentation stays accurate as project evolves without manual tracking of changes.

## Triggers
When should an AI agent invoke this procedure?
- New procedure added to `context/procedures/`
- New installation bundle added to `context/installation_bundles/`
- Project structure changes significantly
- User reports documentation out of sync
- As part of pre-commit workflow

## Prerequisites
**Common:** See common_patterns.md#standard-prerequisites

**Specific:**
- `README.md` exists in repository root
- Project follows standard directory structure
- Procedure directories contain context.md files

## Logic
Maintenance workflow:
1. Scan `context/procedures/` for all procedure directories
2. Extract procedure names and descriptions from context.md files
3. Scan `context/installation_bundles/` for bundles
4. Compare with current README.md content
5. If differences found → Generate updates
6. Show diff to user for approval
7. Apply changes to README.md

## Related Files
- `README.md` - Main project documentation
- `context/procedures/*/context.md` - Source of procedure info
- `context/installation_bundles/*/context.md` - Source of bundle info

## AI Agent Notes
**Safety:** ASK | Modifies documentation, show diff first

**User Interaction:** Always show diff before applying, get approval

**Common Issues:** See common_patterns.md#permission-denied

**Procedure-Specific:**
- README structure changed → May need manual review
- Procedure missing description → Use directory name as fallback
- Multiple updates needed → Batch into single commit
- User customized README → Preserve custom sections, only update procedure list

**Best Practice:** Run before committing new procedures or bundles
