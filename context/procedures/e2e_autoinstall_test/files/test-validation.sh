#!/bin/bash
# E2E Autoinstall Validation Script
# Runs on the newly installed Ubuntu system to verify configuration
# Note: Not using set -e because validation checks should continue on failure

echo "=== Starting E2E Validation ==="
echo "Timestamp: $(date -Iseconds)"
echo ""

# Track validation results
PASSED=0
FAILED=0
WARNINGS=0

# Helper functions
pass() {
    echo "✅ PASS: $1"
    PASSED=$((PASSED + 1))
}

fail() {
    echo "❌ FAIL: $1"
    FAILED=$((FAILED + 1))
}

warn() {
    echo "⚠️  WARN: $1"
    WARNINGS=$((WARNINGS + 1))
}


# 1. System Information
echo "--- System Information ---"
echo "Hostname: $(hostname)"
echo "OS: $(lsb_release -ds 2>/dev/null || cat /etc/os-release | grep PRETTY_NAME | cut -d= -f2)"
echo "Kernel: $(uname -r)"
echo ""

# 2. Check SSH Service
echo "--- SSH Service ---"
if systemctl is-enabled ssh &>/dev/null; then
    pass "SSH service is enabled"
else
    fail "SSH service is NOT enabled"
fi

if systemctl is-active ssh &>/dev/null; then
    pass "SSH service is running"
else
    fail "SSH service is NOT running"
fi
echo ""

# 3. Check Expected Packages
echo "--- Package Verification ---"
EXPECTED_PACKAGES=(
    "ubuntu-desktop-minimal"
    "git"
    "neofetch"
    "net-tools"
)

for pkg in "${EXPECTED_PACKAGES[@]}"; do
    if dpkg -l "$pkg" &>/dev/null; then
        pass "Package installed: $pkg"
    else
        warn "Package NOT installed: $pkg (may be optional)"
    fi
done
echo ""

# 4. Check Locale
echo "--- Locale ---"
CURRENT_LOCALE=$(locale | grep LANG= | cut -d= -f2)
if [[ -n "$CURRENT_LOCALE" ]]; then
    pass "Locale configured: $CURRENT_LOCALE"
else
    warn "Locale not set"
fi
echo ""

# 5. Check User Configuration
echo "--- User Configuration ---"
CURRENT_USER=$(whoami)
if id "$CURRENT_USER" &>/dev/null; then
    pass "User exists: $CURRENT_USER"
else
    fail "Current user not found"
fi

if groups "$CURRENT_USER" | grep -q sudo; then
    pass "User in sudo group"
else
    warn "User NOT in sudo group"
fi
echo ""

# 6. Check Disk Space
echo "--- Disk Space ---"
ROOT_USAGE=$(df / | tail -1 | awk '{print $5}' | tr -d '%')
if [[ $ROOT_USAGE -lt 90 ]]; then
    pass "Root partition usage: ${ROOT_USAGE}%"
else
    warn "Root partition usage high: ${ROOT_USAGE}%"
fi
echo ""

# 7. Check Network
echo "--- Network ---"
if ip route | grep -q default; then
    pass "Default route configured"
else
    fail "No default route"
fi

if ping -c 1 -W 5 8.8.8.8 &>/dev/null; then
    pass "Internet connectivity (ping)"
else
    warn "No internet connectivity"
fi
echo ""

# 8. Check for Installation Errors in Logs
echo "--- Installation Logs ---"
if [[ -f /var/log/installer/autoinstall-user-data ]]; then
    pass "Autoinstall user-data logged"
fi

# Check for errors in syslog related to installation
if journalctl -b | grep -qi "error.*autoinstall"; then
    warn "Possible autoinstall errors in journal"
else
    pass "No autoinstall errors in journal"
fi
echo ""

# Summary
echo "=== Validation Summary ==="
echo "Passed:   $PASSED"
echo "Failed:   $FAILED"
echo "Warnings: $WARNINGS"
echo ""

if [[ $FAILED -gt 0 ]]; then
    echo "❌ VALIDATION FAILED - Review errors above"
    exit 1
else
    echo "✅ VALIDATION PASSED"
    exit 0
fi
