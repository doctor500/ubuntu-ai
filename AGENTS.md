# AGENTS.md — Ubuntu Desktop Autoinstall Project

## Project Context Gate (MANDATORY)

**Read before any plan or action. Write after any state change.**

All agents working in this repo **MUST** follow the gate protocol defined in
`context/governance.md` (top section: "Project Context Gate").

### Read order (BEFORE)

```
context/governance.md          ← gate + protocols (START HERE)
  → context/change_log.md      ← project structural changes (tail)
    → context/vm_update_log.md ← package/bundle updates (tail)
      → context/procedures/<name>/procedure.md  ← task-specific
```

### Reply format

- **BEFORE any plan:** "Context checked: [files read · last-known state · pending items]"
- **AFTER state change:** "Context updated: [files changed · commit · links]"

## KB references

- `@knowledge:project-context-gate-protocol` — authoritative gate definition
- `@knowledge:decisions-for-channel-channel-24f1e8ba` — confirmed decisions
- `@knowledge:session-start-checklist-for-ubuntu-desktop` — session start checklist

## Repo structure

| Path | Purpose |
|------|---------|
| `context/governance.md` | Interaction modes + context gate |
| `context/change_log.md` | Project structural changes (tracked) |
| `context/vm_update_log.md` | Package/bundle update history (gitignored) |
| `context/procedures/` | 14 operational procedures |
| `context/installation_bundles/` | 4 installable bundles (kubeadm, shell_tools, etc.) |
| `scripts/` | Validation and utility scripts |

## Procedures

Key procedures for daily operations:
- `update_system/` — scan, apply, and log APT/Homebrew updates
- `reboot_vm/` — graceful single-node K8s reboot (cordon → reboot → verify → uncordon)
- `verify_vm/` — compare live VM state with configuration
- `validate_config/` — validate autoinstall.yaml syntax
