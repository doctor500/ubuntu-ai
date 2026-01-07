# Ubuntu Desktop Autoinstall Project

This repository manages the configuration and state synchronization for an Ubuntu Desktop VM (e.g., `your-vm-hostname`). It uses Canonical's **autoinstall** format to define the system state (packages, identity, network) and includes procedures for verifying and synchronizing that state with a live VM.

## Project Structure

### `context/`
The core directory containing all configuration and documentation.

*   **`autoinstall.example.yaml`**: Template configuration file with dummy/placeholder values (safe to commit).
*   **`autoinstall.yaml`**: (Ignored by git) Your personalized configuration defining the desired state of your VM.
*   **`autoinstall-schema.json`**: JSON schema used to validate the YAML config.
*   **`change_log.md`**: (Ignored by git) A history of modifications made to the project (Keep a Changelog format).
*   **`user_data.json`**: (Ignored by git) Stores personalized/sensitive data like IPs and usernames.

### `context/installation_bundles/`
Optional software packages with installation procedures:

*   **`docker/`**: Docker Engine installation (historical reference, containerd used instead)
*   **`kubeadm/`**: Single-node Kubernetes cluster (kubeadm, kubelet, kubectl, nerdctl)

### `context/procedures/`
Standardized procedures with `context.md` (why/when) and `procedure.md` (how) pattern:

*   **`add_late_command/`**: Add post-installation commands to autoinstall configuration.
*   **`exclude_bundles/`**: Generate variant configs that exclude specific installation bundles.
*   **`init_autoinstall/`**: Initialize `autoinstall.yaml` from the example template.
*   **`init_change_log/`**: Initialize change log with Keep a Changelog format.
*   **`init_user_data/`**: Initialize VM connection data file.
*   **`maintain_docs/`**: Keep `README.md` synchronized with project structure.
*   **`passwordless_sudo/`**: Configure passwordless sudo for frictionless administration.
*   **`ssh_key_auth/`**: Set up passwordless SSH key authentication.
*   **`validate_config/`**: Validate `autoinstall.yaml` syntax against schema.
*   **`verify_script/`**: Verify and safely execute scripts from URLs or local files.
*   **`verify_vm/`**: Verify live VM state matches configuration.

## Quick Start

1.  **Initialize Configuration:**
    Create your personalized config from the template.
    ```bash
    cp context/autoinstall.example.yaml context/autoinstall.yaml
    # Edit context/autoinstall.yaml with your hostname, username, and password hash
    # Generate password hash: mkpasswd -m sha-512 "YourPassword"
    ```

2.  **Initialize User Data:**
    Ensure `context/user_data.json` exists with your VM details.
    ```bash
    # See context/procedures/init_user_data/procedure.md
    ```

3.  **Validate Configuration:**
    ```bash
    # See context/procedures/validate_config/procedure.md
    ```

4.  **Verify Live VM:**
    ```bash
    # See context/procedures/verify_vm/procedure.md
    ```

## Usage
This repo is designed to be used by an AI Agent. You ask the agent to "install X" or "sync config," and it uses the procedures in `context/` to execute the task safely and update `autoinstall.yaml`.
