# Architecture — Ubuntu Desktop Autoinstall

## Repo layout

| Path | Purpose |
|------|---------|
| `autoinstall-schema.json` | JSON schema for autoinstall.yaml |
| `autoinstall.example.yaml` | Example autoinstall config |
| `user_data.json` | User-data payload for cloud-init/autoinstall |
| `context/governance.md` | Project Context Gate + interaction modes |
| `context/change_log.md` | Project structural changes (tracked) |
| `context/vm_update_log.md` | Package/bundle update history (gitignored) |
| `context/procedures/` | 14 operational procedures (see below) |
| `context/installation_bundles/` | docker, kubeadm, packer_qemu, shell_tools |
| `context/common_patterns.md` | Reusable patterns across procedures |
| `scripts/` | init_project.sh, validate_config.sh, verify_script.sh |

## Procedures (context/procedures/)

- `init_*` — autoinstall / change_log / user_data initialization
- `validate_config` — validate autoinstall.yaml syntax against the schema
- `verify_vm`, `verify_script`, `e2e_autoinstall_test` — verification
- `update_system` — scan, apply, log APT/Homebrew updates
- `reboot_vm` — graceful single-node K8s reboot (cordon → reboot → verify → uncordon)
- `add_late_command`, `exclude_bundles`, `passwordless_sudo`, `ssh_key_auth` — provisioning tweaks
- `maintain_docs` — docs maintenance

## Data flow

1. `autoinstall.yaml` + `user_data.json` define the target VM state.
2. `scripts/validate_config.sh` validates against `autoinstall-schema.json`.
3. Bundles (`installation_bundles/`) install runtimes (docker, kubeadm, shell_tools).
4. Procedures mutate VM state; every mutation is recorded in the logs
   (`change_log.md` tracked, `vm_update_log.md` gitignored).
5. `verify_vm` compares live VM state with configuration.

## Agent context flow

Root `AGENTS.md` is the gate entry → `context/governance.md` (read order) →
`.agents/` for standard project context (this folder) → `context/procedures/` for
task-specific runbooks.
