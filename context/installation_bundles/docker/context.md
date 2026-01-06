# Docker Installation Bundle Context

## Overview
Install Docker Engine (Community Edition) and associated plugins (Buildx, Compose) on Ubuntu 24.04.

## Goal
Set up a complete Docker development and deployment environment on the target VM, including the Docker daemon, CLI tools, container runtime, and modern build/compose plugins. This enables container-based workflows and microservices deployment.

## Triggers
When should an AI agent invoke this procedure?
- User requests Docker installation
- Setting up development environment requiring containers
- Provisioning VM for containerized applications
- Following autoinstall.yaml that includes docker-ce packages
- When "docker" command not found on target VM

## Prerequisites
Required before running:
- Ubuntu 24.04 LTS (or compatible version)
- Internet connectivity (to download packages)
- Sudo privileges on target VM
- At least 20GB free disk space (recommended)
- `context/user_data.json` with VM connection details

## Logic
Step-by-step installation flow:
1. **Clean up old versions:**
   - Remove conflicting packages (docker.io, podman-docker, etc.)
2. **Set up Docker repository:**
   a. Install prerequisites (ca-certificates, curl)
   b. Add Docker's official GPG key
   c. Add Docker repository to apt sources
   d. Update apt package index
3. **Install Docker packages:**
   - docker-ce (daemon and engine)
   - docker-ce-cli (command-line interface)
   - containerd.io (container runtime)
   - docker-buildx-plugin (extended build capabilities)
   - docker-compose-plugin (compose v2)
4. **Post-installation configuration:**
   a. Add user to docker group (non-root access)
   b. Note: User needs to log out/in for group to take effect
5. **Verification:**
   - Run hello-world container
   - Confirm Docker version
6. **Update autoinstall.yaml** with Docker packages and repository

## Components Installed
- **docker-ce**: Docker daemon and engine
- **docker-ce-cli**: Command-line interface for Docker
- **containerd.io**: Industry-standard container runtime
- **docker-buildx-plugin**: Extended build capabilities with BuildKit
- **docker-compose-plugin**: Docker Compose v2 (docker compose command)

## Dependencies
System packages required before Docker installation:
- `ca-certificates` - SSL certificate validation
- `curl` - Download GPG keys and packages
- `gnupg` - GPG key management (usually pre-installed)

## Related Files
- `installation_bundles/docker/procedure.md` - Step-by-step installation commands
- `context/autoinstall.yaml` - Should list docker packages after installation
- `context/user_data.json` - Provides `{{vm_username}}` for docker group
- `procedures/verify_vm/` - Can verify Docker installation
- `procedures/exclude_bundles/` - Can generate config without Docker

## Verification Source
Official Documentation: [https://docs.docker.com/engine/install/ubuntu/](https://docs.docker.com/engine/install/ubuntu/)

**Important:** Always verify installation method is current by checking official docs.

## AI Agent Notes
- **Auto-run Safety:** REQUIRES SUDO - Must ask user before installing
- **User Interaction:**
  - Confirm user wants Docker installed
  - Warn about disk space requirements
  - Explain docker group and logout requirement
  - Show verification test results
- **Common Failures:**
  - Conflicting packages not removed → Run cleanup step
  - Repository GPG key expired → Verify docs for current key
  - Network issues during download → Check connectivity
  - Permission denied running docker → User not in docker group or not logged out/in
- **Edge Cases:**
  - Docker already partially installed → Clean reinstall recommended
  - Old docker.io version present → Must remove first
  - Custom apt sources interfere → May need manual intervention
  - ARM architecture VM → Verify Docker supports architecture
- **Error Handling:**
  - If apt-get fails, check internet connection
  - If GPG key fails, verify URL hasn't changed
  - If hello-world test fails, check docker service status
- **Post-Installation:**
  - User must logout/login for docker group to activate
  - Or use `newgrp docker` temporarily in current session
  - Verify with: `docker run --rm hello-world`
- **Security:** Consider enabling Docker rootless mode for production
- **Updates:** Check official docs before installation - procedures may change