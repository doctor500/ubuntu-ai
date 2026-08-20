# Conventions — Ubuntu Desktop Autoinstall

## Project Context Gate (mandatory, from context/governance.md)

- **BEFORE any plan/action:** "Context checked: [files read · last-known state · pending items]"
- **AFTER any state change:** "Context updated: [files changed · commit · links]"
- Read order: `context/governance.md` → `context/change_log.md` (tail) →
  `context/vm_update_log.md` (tail) → `context/procedures/<name>/procedure.md`.

## Procedure conventions

- One procedure per directory under `context/procedures/<name>/procedure.md`.
- Reusable steps live in `context/common_patterns.md` — reference, don't duplicate.
- Every procedure documents its verify step (see `verify_vm`, `verify_script`).
- Validate autoinstall changes with `scripts/validate_config.sh` before applying.

## Logging

- Structural change → append `context/change_log.md` (tracked, committed).
- Package/bundle update → append `context/vm_update_log.md` (gitignored, machine-local).

## Content rules

- One fact = one home. Operational facts stay in `context/`; standard project
  context lives in `.agents/`; shims only point.
- Never restate facts in CLAUDE.md/GEMINI.md/other shims — they import AGENTS.md.
