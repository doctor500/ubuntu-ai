# Change Log Initialization Procedure

## 1. Verify File Existence
Check if the file exists in the context directory.
```bash
ls context/change_log.md
```

## 2. Action Based on Result

### Case A: File Exists
**Action:** Do nothing. The file is ready for use.
- Proceed with the intended logging operation (add new version entry or update existing)

### Case B: File Does NOT Exist (Error or exit code 2)
**Action:** Create the file with the Keep a Changelog standard header and initial version.

#### Step 1: Create File with Standard Header

Use the following template to create `context/change_log.md`:

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - <CURRENT_DATE>

### Added
- Initial project setup
- Change log file initialized

### Changed
- N/A

### Fixed
- N/A

### Security
- N/A
```

**Replace `<CURRENT_DATE>` with the actual date in `YYYY-MM-DD` format.**

#### Step 2: Write to File
```bash
cat > context/change_log.md << 'EOF'
[... paste template above ...]
EOF
```

Or use the `write_to_file` tool.

## 3. Post-Condition
The file `context/change_log.md` exists and is ready for entries to be added following the Keep a Changelog standard.

---

## 4. Adding New Entries (When File Exists)

### Determine Version Number
Use Semantic Versioning (MAJOR.MINOR.PATCH):
- **MAJOR**: Breaking changes (e.g., 1.0.0 → 2.0.0)
- **MINOR**: New features, backwards-compatible (e.g., 0.1.0 → 0.2.0)
- **PATCH**: Bug fixes, backwards-compatible (e.g., 0.1.1 → 0.1.2)

**For this project:**
- Increment **MINOR** when adding new procedures, bundles, or features
- Increment **PATCH** when fixing bugs or documentation errors
- Use **0.x.x** until production-ready, then move to **1.0.0**

### Add New Version Entry

Insert a new version block **after** the `[Unreleased]` section:

```markdown
## [Unreleased]

## [X.Y.Z] - YYYY-MM-DD

### Added
- List new features, files, procedures

### Changed
- List modifications to existing functionality

### Deprecated
- List features marked for future removal (if any)

### Removed
- List deleted features or files (if any)

### Fixed
- List bug fixes (if any)

### Security
- List security-related changes (if any)

## [Previous Version] - Previous Date
...
```

### Category Guidelines

**Added** - Use for:
- New files or directories
- New features
- New procedures
- New installation bundles
- New capabilities

**Changed** - Use for:
- Modified files
- Updated documentation
- Configuration changes
- Refactoring

**Deprecated** - Use for:
- Features planned for removal
- Old methods being phased out

**Removed** - Use for:
- Deleted files
- Removed features
- Git history cleanup

**Fixed** - Use for:
- Bug corrections
- Error fixes
- Validation issues resolved

**Security** - Use for:
- Security vulnerabilities addressed
- Sensitive data handling
- Authentication/authorization changes
- Gitignore updates for sensitive files

### Example Entry

```markdown
## [0.3.0] - 2026-01-07

### Added
- Created `context/procedures/new_feature/` for automated deployments
- Added support for multiple VM configurations

### Changed
- Updated `README.md` with deployment instructions
- Improved validation error messages

### Fixed
- Fixed password hash validation in autoinstall template
- Corrected typo in docker bundle procedure

### Security
- Updated SSH key permissions check in ssh_key_auth procedure
```

## 5. Best Practices

1. **Keep entries concise but descriptive**
   - ✅ "Created `context/procedures/init_autoinstall/` for handling missing config files"
   - ❌ "Added stuff"

2. **Use backticks for code/file references**
   - `autoinstall.yaml`, `README.md`, `docker-ce`

3. **Group related changes together**
   - Multiple related changes can be one bullet point

4. **Prioritize Security entries**
   - Always include security-related changes
   - Mark critical issues with **CRITICAL** prefix

5. **Update regularly**
   - Add entries immediately after making changes
   - Don't wait until end of session

6. **Version appropriately**
   - Don't skip versions
   - Use [Unreleased] for work in progress
