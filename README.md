# Ubuntu Desktop Autoinstall Project

This repository manages the configuration and state synchronization for an Ubuntu Desktop VM (e.g., `your-vm-hostname`). It uses Canonical's **autoinstall** format to define the system state (packages, identity, network) and includes procedures for verifying and synchronizing that state with a live VM.

## Project Structure

### `context/`
The core directory containing all configuration and documentation.

*   **`autoinstall.example.yaml`**: Template configuration file with dummy/placeholder values (safe to commit).
*   **`autoinstall.yaml`**: (Ignored by git) Your personalized configuration defining the desired state of your VM.
*   **`autoinstall-schema.json`**: JSON schema used to validate the YAML config.
*   **`change_log.md`**: (Ignored by git) A history of modifications made to the project.
*   **`user_data.json`**: (Ignored by git) Stores personalized/sensitive data like IPs and usernames.
*   **`live_vm_verification.md`**: Procedures to check the live VM state against the config.
*   **`validation_procedure.md`**: How to validate `autoinstall.yaml` syntax.

### `context/installation_bundles/`
Contains "Bundles" for complex installations (e.g., Docker) that require multiple steps/packages.
*   **Example:** `docker/` contains the context and procedure for installing Docker Engine.

### `context/procedures/`
*   **`exclude_bundles/`**: How to generate configs that exclude specific bundles.
*   **`init_change_log/`**: How to recover a missing change log.
*   **`init_user_data/`**: How to initialize the sensitive data file.
*   **`maintain_docs/`**: How to keep `README.md` synchronized with project structure.
*   **`ssh_key_auth/`**: How to set up passwordless SSH access.

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
    # See context/validation_procedure.md
    ```

4.  **Verify Live VM:**
    ```bash
    # See context/live_vm_verification.md
    ```

## Usage
This repo is designed to be used by an AI Agent. You ask the agent to "install X" or "sync config," and it uses the procedures in `context/` to execute the task safely and update `autoinstall.yaml`.
