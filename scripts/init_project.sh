#!/bin/bash
# init_project.sh - Initialize project files for ubuntu-desktop autoinstall
# Usage: ./scripts/init_project.sh

set -e

CONTEXT_DIR="context"
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_info() { echo -e "${YELLOW}[INFO]${NC} $1"; }
log_skip() { echo -e "${CYAN}[SKIP]${NC} $1"; }

echo "=== Ubuntu Desktop Autoinstall - Project Initialization ==="
echo ""

# ===== 1. Initialize autoinstall.yaml =====
if [ ! -f "$CONTEXT_DIR/autoinstall.yaml" ]; then
    if [ -f "$CONTEXT_DIR/autoinstall.example.yaml" ]; then
        cp "$CONTEXT_DIR/autoinstall.example.yaml" "$CONTEXT_DIR/autoinstall.yaml"
        log_success "Created autoinstall.yaml from template"
    else
        log_info "No template found, creating minimal autoinstall.yaml"
        cat > "$CONTEXT_DIR/autoinstall.yaml" << 'EOF'
#cloud-config
autoinstall:
  version: 1
  identity:
    hostname: ubuntu-vm
    username: ubuntu
    password: "$6$rounds=4096$xyz$..." # Generate with: echo 'password' | openssl passwd -6 -stdin
  locale: en_US.UTF-8
  keyboard:
    layout: us
  ssh:
    install-server: true
    allow-pw: true
EOF
        log_success "Created minimal autoinstall.yaml"
    fi
else
    log_skip "autoinstall.yaml already exists"
fi

# ===== 2. Initialize user_data.json =====
if [ ! -f "$CONTEXT_DIR/user_data.json" ]; then
    cat > "$CONTEXT_DIR/user_data.json" << 'EOF'
{
  "vm_ip": "",
  "vm_username": "",
  "vm_hostname": ""
}
EOF
    log_success "Created user_data.json"
else
    log_skip "user_data.json already exists"
fi

# ===== 3. Initialize change_log.md =====
if [ ! -f "$CONTEXT_DIR/change_log.md" ]; then
    cat > "$CONTEXT_DIR/change_log.md" << 'EOF'
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]

### Added
- Initial project setup

EOF
    log_success "Created change_log.md"
else
    log_skip "change_log.md already exists"
fi

echo ""
log_success "Project initialization complete!"
echo ""
echo "Next steps:"
echo "  1. Edit context/autoinstall.yaml:"
echo "     - Set hostname, username"
echo "     - Generate password hash: echo 'password' | openssl passwd -6 -stdin"
echo ""
echo "  2. Fill in context/user_data.json with VM connection details"
echo ""
echo "  3. Validate configuration:"
echo "     ./scripts/validate_config.sh"
