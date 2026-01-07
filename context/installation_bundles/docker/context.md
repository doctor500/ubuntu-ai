# Docker Installation Bundle Context

## Overview
Install Docker Engine (CE) with Buildx and Compose plugins on Ubuntu 24.04.

**Note:** This bundle is historical reference. Current config uses standalone containerd.io for Kubernetes.

## Goal
Complete Docker development environment with daemon, CLI, and plugins.

## Triggers
- User requests Docker installation
- Setting up container development environment
- Following autoinstall.yaml with docker-ce packages

## Prerequisites
See common_patterns.md#standard-prerequisites

**Specific:** Ubuntu 24.04, 20GB disk, sudo access, internet

## Components

| Package | Purpose |
|---------|---------|
| docker-ce | Docker Engine |
| docker-ce-cli | CLI |
| containerd.io | Runtime |
| docker-buildx-plugin | BuildKit |
| docker-compose-plugin | Compose v2 |

## Logic
1. Remove conflicting packages (docker.io, podman-docker)
2. Add Docker GPG key and repository
3. Install docker-ce and plugins
4. Add user to docker group
5. Verify with hello-world

## Related Files
- `docker/procedure.md` - Step-by-step commands
- Official docs: https://docs.docker.com/engine/install/ubuntu/

## AI Agent Notes

**Safety:** ASK | Requires sudo

**Interaction:** Confirm install, explain docker group logout requirement

**Issues:** See common_patterns.md#network-timeout, #permission-denied

**Specific:**
- Conflicting packages → Run cleanup first
- Permission denied → Add user to docker group, logout/login
- GPG key failed → Check official docs for current key
- Verify: `docker run --rm hello-world`