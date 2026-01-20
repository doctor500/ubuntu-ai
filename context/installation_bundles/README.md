# Installation Bundle Procedure

This document outlines the standard for managing complex installation tasks that require multiple packages, manual builds, or specific configurations. All such tasks must be encapsulated in an **Installation Bundle** within the `context/installation_bundles/` directory.

## Bundle Structure
For each distinct installation task (e.g., "docker", "custom_python_build"), create a folder:
`context/installation_bundles/<bundle_name>/`

Inside this folder, the following files are required:

### 1. `procedure.md`
Contains the step-by-step commands and logic for the installation.
- **Format:** Markdown with code blocks.
- **Content:**
    - **Pre-requisites:** Dependencies or system state requirements.
    - **Verification Step:** A specific command or check to ensure the installation method is still valid/up-to-date (e.g., checking a URL for the latest version).
    - **Execution Steps:** The actual shell commands to run.
    - **Post-Install Verification:** How to test that the installation was successful.

### 2. `context.md`
A descriptive file for the AI Agent.
- **Purpose:** Explains *what* this bundle does and *why*.
- **Dependencies:** Lists other system packages or bundles this relies on.
- **Packages Installed:** A list of `apt` packages installed by this bundle, e.g.:
  ```
  Packages Installed:
  - package-name-1
  - package-name-2
  ```
- **Maintainer Notes:** Any specific warnings or "gotchas" for the AI.

### 3. `files/` (Optional Directory)
Stores any static configuration files, scripts, or patches required by the `procedure.md`.

## Execution Workflow
When a user requests an installation that matches an existing bundle:

1.  **Locate Bundle:** Find the matching folder in `context/installation_bundles/`.
2.  **Read Context:** Analyze `context.md` to understand the goal.
3.  **Verify Freshness:** **CRITICAL:** Before running *any* installation commands, the AI Agent must verify the method is up-to-date.
    - *Example:* If the procedure downloads `v1.0.0`, check the vendor's site/repo to see if `v1.2.0` is now standard.
    - If outdated, update `procedure.md` first.
4.  **Execute:** Run the steps defined in `procedure.md`.
5.  **Update Config:** If the bundle installs system packages that should be permanent, update `context/autoinstall.yaml` and `context/change_log.md`.

---

## Current Versions

| Component | Version | Bundle | Last Updated |
|-----------|---------|--------|--------------|
| Kubernetes | v1.31.14 | kubeadm | 2026-01-07 |
| containerd | Latest | kubeadm | 2026-01-07 |
| nerdctl | v2.2.1 | kubeadm | 2026-01-07 |
| Homebrew | Latest | shell_tools | Dynamic |
| Oh My Zsh | Latest | shell_tools | Dynamic |
| K9s | v0.50.18 | shell_tools | 2026-01-16 |
| Packer | Latest | packer_qemu | Dynamic |
| QEMU | System | packer_qemu | Dynamic |

**Note:** "Latest" = installed via package manager, auto-updated. "Dynamic" = version determined at install time.

---

## Procedure Dependencies

```
init_autoinstall ─────┬──→ validate_config ──→ e2e_autoinstall_test
                      │
init_user_data ───────┼──→ verify_vm
                      │
                      └──→ update_system

add_late_command ──→ verify_script ──→ validate_config
```

| Procedure | Requires First |
|-----------|----------------|
| `e2e_autoinstall_test` | `validate_config` |
| `add_late_command` | `verify_script` |
| `verify_vm` | `init_user_data` |
| `update_system` | `init_user_data` |

