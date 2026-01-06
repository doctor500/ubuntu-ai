# Documentation Maintenance Context

## Overview
Keep README.md synchronized with project structure as files and procedures are added or modified.

## Goal
Ensure the `README.md` file accurately reflects the current project structure, available procedures, and installation bundles. The README serves as the primary entry point for users and AI agents, so it must stay up-to-date as the project evolves.

## Triggers
When should an AI agent invoke this procedure?
- A new file or directory is created in `context/`
- A new procedure is added to `context/procedures/`
- A new installation bundle is added to `context/installation_bundles/`
- Significant changes to existing file purposes or descriptions
- After completing major project reorganization
- Before committing structural changes to git

## Prerequisites
Required before running:
- `README.md` must exist in project root
- Clear understanding of what changed in project structure
- No sensitive data in descriptions (IPs, personal hostnames, etc.)

## Logic
Step-by-step maintenance flow:
1. Detect structural change (new procedure, bundle, or file)
2. Read current `README.md` content
3. Identify relevant section to update:
   - `context/` section for top-level files
   - `context/procedures/` section for new procedures
   - `context/installation_bundles/` section for new bundles
4. Check if new item is already documented
5. If missing:
   a. Determine appropriate insertion point (alphabetical or logical order)
   b. Draft description (1-2 sentences, no sensitive data)
   c. Update README with new entry
   d. Format consistently with existing entries
6. Verify sensitive data check (no IPs, specific hostnames, etc.)
7. Save updated README
8. Offer to show diff for user review

## Related Files
- `README.md` - The file being maintained (project root)
- All `context/procedures/*/context.md` - Source of procedure descriptions
- All `installation_bundles/*/context.md` - Source of bundle descriptions
- `.gitignore` - Ensure documented files aren't gitignored
- `change_log.md` - May want to log README updates

## AI Agent Notes
- **Auto-run Safety:** SAFE but SHOW DIFF - Auto-update is safe, but show changes
- **User Interaction:**
  - Display proposed README changes before committing
  - Ask if description accurately reflects purpose
  - Confirm no sensitive data included
- **Common Failures:**
  - README formatting broken → Parse carefully, maintain markdown structure
  - Duplicate entries → Check before adding
  - Inconsistent descriptions → Match existing style and detail level
- **Edge Cases:**
  - Multiple items added simultaneously → Update all in one edit
  - Renamed procedures → Update existing entry rather than add new
  - Deprecated procedures → Mark as deprecated, don't remove yet
  - Procedure moved to different category → Update location in README
- **Error Handling:**
  - If README parse fails, show manual update instructions
  - If uncertain about description, ask user
  - If can't determine section, list options for user
- **Best Practices:**
  - Use generic terms ("VM" not "davidlay-NUC13ANKi7")
  - Keep descriptions concise (under 10 words if possible)
  - Match existing list format exactly
  - Maintain alphabetical or logical ordering
- **Validation:** Check that README still renders properly after updates
