# Project — Ubuntu Desktop Autoinstall

## Overview

Automated provisioning and maintenance of an Ubuntu Desktop VM that serves as a
single-node Kubernetes host. The repo is the source of truth for the autoinstall
configuration (`autoinstall.yaml` schema + example, `user_data.json`), validation
scripts, and the operational context: 14 procedures, 4 installation bundles, and
change/update logs.

## Ownership & Access

- **Owner:** doctor500 (personal repo, direct commits)
- **Deployment target:** Ubuntu Desktop VM (QEMU/Packer) on the Mac
- **Context gate:** MANDATORY — see `context/governance.md`; applies to all agents

## Scope

**In scope:** autoinstall config + validation, VM provisioning bundles (docker,
kubeadm, packer_qemu, shell_tools), operational procedures (update/reboot/verify),
change and update logging.

**Out of scope:** application workloads on the cluster; anything not covered by a
procedure in `context/procedures/`.

## Key Links

- Root `AGENTS.md` — gate protocol + read order (start here)
- `context/governance.md` — authoritative gate definition
- `context/procedures/` — 14 operational procedures
- `context/installation_bundles/` — 4 installable bundles
- `autoinstall-schema.json`, `autoinstall.example.yaml`, `user_data.json` — provisioning source
