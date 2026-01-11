#!/bin/bash
# validate_config.sh - Validate autoinstall.yaml syntax and structure
# Usage: ./scripts/validate_config.sh [config_file]
#
# This script performs lightweight local validation:
# - YAML syntax check
# - Required fields check
# - Basic structure validation
#
# For full runtime validation, use the E2E Packer test.

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
CONFIG="${1:-context/autoinstall.yaml}"

log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_info() { echo -e "${YELLOW}[INFO]${NC} $1"; }
log_step() { echo -e "${CYAN}[STEP]${NC} $1"; }

# Check if config file exists
if [ ! -f "$CONFIG" ]; then
    log_error "Config file not found: $CONFIG"
    exit 1
fi

echo "=== Autoinstall Config Validation ==="
log_info "File: $CONFIG"
echo ""

# ===== Step 1: YAML Syntax Check =====
log_step "Checking YAML syntax..."

if python3 -c "import yaml; yaml.safe_load(open('$CONFIG'))" 2>/dev/null; then
    log_success "YAML syntax is valid"
elif /usr/bin/python3 -c "import yaml; yaml.safe_load(open('$CONFIG'))" 2>/dev/null; then
    log_success "YAML syntax is valid"
else
    log_error "YAML syntax error or PyYAML not installed"
    log_info "Install with: pip3 install pyyaml"
    exit 1
fi

# ===== Step 2: Required Fields Check =====
log_step "Checking required fields..."

ERRORS=0

check_field() {
    if grep -q "$1:" "$CONFIG"; then
        log_success "$1"
    else
        log_error "$1 is MISSING"
        ERRORS=$((ERRORS + 1))
    fi
}

check_field "version"
check_field "identity"
check_field "ssh"

# ===== Step 3: Structure Check =====
log_step "Checking structure..."

# Check if version is 1
if grep -qE "^\s*version:\s*1" "$CONFIG"; then
    log_success "version: 1"
else
    log_info "version should be 1 for autoinstall"
fi

# Check identity has hostname and username
if grep -qE "hostname:" "$CONFIG"; then
    log_success "hostname defined"
else
    log_error "hostname missing in identity"
    ERRORS=$((ERRORS + 1))
fi

if grep -qE "username:" "$CONFIG"; then
    log_success "username defined"
else
    log_error "username missing in identity"
    ERRORS=$((ERRORS + 1))
fi

# Check SSH settings
if grep -qE "install-server:\s*true" "$CONFIG"; then
    log_success "SSH server will be installed"
else
    log_info "SSH server not enabled (install-server: true)"
fi

echo ""
echo "=== Summary ==="

if [ $ERRORS -eq 0 ]; then
    log_success "Validation passed! Config looks good."
    echo ""
    log_info "For full runtime validation, run E2E test:"
    echo "  ./context/procedures/e2e_autoinstall_test/files/run-e2e-test.sh"
    exit 0
else
    log_error "$ERRORS error(s) found. Please fix before deployment."
    exit 1
fi
