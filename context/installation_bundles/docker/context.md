# Docker Installation Context

## Goal
Install the latest Docker Engine (Community Edition) and its associated plugins (Buildx, Compose) on Ubuntu 24.04.

## Components
- **docker-ce**: The Docker daemon and engine.
- **docker-ce-cli**: The command-line interface.
- **containerd.io**: The container runtime.
- **docker-buildx-plugin**: Extended build capabilities.
- **docker-compose-plugin**: `docker compose` command support.

## Dependencies
- `ca-certificates`
- `curl`
- `gnupg` (usually present, but verified)

## Post-Installation
- The current user (`{{vm_username}}` from `context/user_data.json`) must be added to the `docker` group to run commands without `sudo`.
- A test container (`hello-world`) is run to verify functionality.

## Verification Source
Official Docs: [https://docs.docker.com/engine/install/ubuntu/](https://docs.docker.com/engine/install/ubuntu/)

### Packages Installed:
- docker-ce
- docker-ce-cli
- containerd.io
- docker-buildx-plugin
- docker-compose-plugin