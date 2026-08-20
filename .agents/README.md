# Project Context Index

This folder is the canonical context for this project — the single place agents read from
and write to. Platform shims (CLAUDE.md, .cursorrules, GEMINI.md, .windsurfrules,
.aider.conf.yml) and AGENTS.md all point here.

> **Note:** This repo ALSO has an operational `context/` folder (non-dot) — governance,
> procedures, bundles, logs. It is real project content, not agent context. Root
> `AGENTS.md`'s gate protocol routes there first; this folder holds the standard set.

## Router Table

| Task | Read |
|------|------|
| Orientation | PROJECT.md |
| Design / architecture | ARCHITECTURE.md |
| Coding standards | CONVENTIONS.md |
| Prior decisions | DECISIONS.md |
| Session state / lessons | memory/memory.md |
| Deep reference | docs/README.md |
| **Gate protocol (START)** | `../context/governance.md` |
| **Operational runbooks** | `../context/procedures/` |
| **Change / update logs** | `../context/change_log.md`, `../context/vm_update_log.md` |

## Write Rules

- Facts live in exactly one file. Move + update, never copy.
- Append to DECISIONS.md for decisions with rationale.
- Update memory/memory.md at session end (state, blockers, lessons).
- Never create loose `.md` files at repo root for context — extend this folder.
- Operational changes go to `context/` logs per the gate protocol, not here.
