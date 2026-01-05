# Change Log Initialization Context

## Goal
To ensure the `change_log.md` file exists and follows the [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) standard format before attempting to write to it. This prevents errors when the file is missing and ensures consistency with industry best practices.

## Standard Format
This project uses **Keep a Changelog v1.1.0** format with **Semantic Versioning**:

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [X.Y.Z] - YYYY-MM-DD

### Added
- New features

### Changed
- Changes in existing functionality

### Deprecated
- Soon-to-be removed features

### Removed
- Removed features

### Fixed
- Bug fixes

### Security
- Security-related changes
```

## Change Categories
Changes must be categorized into one of these sections:
- **Added**: New features, files, or capabilities
- **Changed**: Modifications to existing functionality
- **Deprecated**: Features marked for future removal
- **Removed**: Features or files that have been deleted
- **Fixed**: Bug fixes
- **Security**: Security-related changes (vulnerabilities, improvements)

## Triggers
- AI Agent prepares to log an action but suspects the log file might be missing
- `change_log.md` is deleted or corrupted
- Initialization of a new project environment
- First-time repository clone

## Logic
1.  **Check Existence:** Verify if `context/change_log.md` exists
2.  **Create if Missing:** If it does not exist, create it with the standard Keep a Changelog header and an initial version entry
3.  **No-op if Exists:** If it exists, proceed without modifying it (the logging action will handle appending entries)

## Versioning Guidelines
- Use [Semantic Versioning](https://semver.org/): `[MAJOR.MINOR.PATCH]`
- **MAJOR**: Incompatible changes (breaking changes)
- **MINOR**: Add functionality (backwards-compatible)
- **PATCH**: Bug fixes (backwards-compatible)
- For this infrastructure project, increment MINOR for new features/procedures
- Use `[Unreleased]` section for work in progress
