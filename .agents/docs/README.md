# Deep Reference & Runbooks

Operational runbooks live in `context/procedures/<name>/procedure.md` (14 procedures)
and reusable patterns in `context/common_patterns.md`.

## Index of procedures

| Procedure | Purpose |
|-----------|---------|
| `update_system/` | Scan, apply, and log APT/Homebrew updates |
| `reboot_vm/` | Graceful single-node K8s reboot (cordon → reboot → verify → uncordon) |
| `verify_vm/` | Compare live VM state with configuration |
| `validate_config/` | Validate autoinstall.yaml syntax |
| `e2e_autoinstall_test/` | End-to-end autoinstall test |
| others | See `context/procedures/` (init_*, add_late_command, exclude_bundles, passwordless_sudo, ssh_key_auth, maintain_docs, init_change_log, init_user_data, verify_script) |

Installation bundles: `context/installation_bundles/` (docker, kubeadm, packer_qemu, shell_tools).

This folder (`.agents/docs/`) is for standard project reference; repo-specific deep
reference stays in `context/`.
