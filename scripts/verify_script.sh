#!/bin/bash
# verify_script.sh - Securely verify and execute scripts from URLs or files
# Usage: ./scripts/verify_script.sh <url_or_path> [--execute]

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_info() { echo -e "${CYAN}[INFO]${NC} $1"; }

# Trusted domains
TRUSTED_DOMAINS=(
    "raw.githubusercontent.com"
    "get.docker.com"
    "pkgs.k8s.io"
    "packages.cloud.google.com"
    "brew.sh"
    "ohmyz.sh"
    "releases.hashicorp.com"
)

# Dangerous patterns to flag
DANGEROUS_PATTERNS=(
    'rm\s+-rf\s+/'
    'chmod\s+777'
    'mkfs\.'
    'dd\s+if='
    '>\s*/dev/sd'
    ':(){ :|:& };:'
)

SOURCE="$1"
AUTO_EXECUTE="$2"
TEMP_SCRIPT="/tmp/verify_script_$$"

show_help() {
    echo "Usage: $0 <url_or_path> [--execute]"
    echo ""
    echo "Options:"
    echo "  --execute    Execute after verification (still prompts for confirmation)"
    echo ""
    echo "Examples:"
    echo "  $0 https://get.docker.com"
    echo "  $0 ./my-script.sh --execute"
}

if [ -z "$SOURCE" ] || [ "$SOURCE" == "--help" ]; then
    show_help
    exit 0
fi

# Download or copy script
if [[ "$SOURCE" == http* ]]; then
    log_info "Downloading from: $SOURCE"
    
    # Check HTTPS
    if [[ ! "$SOURCE" == https* ]]; then
        log_warn "Non-HTTPS URL detected!"
    fi
    
    # Check trusted domain
    DOMAIN=$(echo "$SOURCE" | awk -F/ '{print $3}')
    TRUSTED=false
    for d in "${TRUSTED_DOMAINS[@]}"; do
        if [[ "$DOMAIN" == *"$d"* ]]; then
            TRUSTED=true
            break
        fi
    done
    
    if [ "$TRUSTED" = true ]; then
        log_success "Domain is trusted: $DOMAIN"
    else
        log_warn "Domain NOT in trusted list: $DOMAIN"
    fi
    
    curl -fsSL "$SOURCE" -o "$TEMP_SCRIPT" || {
        log_error "Failed to download script"
        exit 1
    }
else
    # Local file
    if [ ! -f "$SOURCE" ]; then
        log_error "File not found: $SOURCE"
        exit 1
    fi
    cp "$SOURCE" "$TEMP_SCRIPT"
    log_info "Local file: $SOURCE"
fi

# Get script info
LINES=$(wc -l < "$TEMP_SCRIPT")
SIZE=$(wc -c < "$TEMP_SCRIPT")
log_info "Size: $SIZE bytes, Lines: $LINES"

echo ""
echo "=== Security Scan ==="

# Scan for dangerous patterns
WARNINGS=0
for pattern in "${DANGEROUS_PATTERNS[@]}"; do
    if grep -qE "$pattern" "$TEMP_SCRIPT" 2>/dev/null; then
        log_warn "Dangerous pattern found: $pattern"
        WARNINGS=$((WARNINGS + 1))
    fi
done

if [ $WARNINGS -eq 0 ]; then
    log_success "No dangerous patterns detected"
else
    log_warn "$WARNINGS potential security issues found"
fi

# Show preview
echo ""
echo "=== Script Preview (first 40 lines) ==="
head -40 "$TEMP_SCRIPT"
echo ""
echo "... ($LINES total lines)"
echo ""

# Prompt for execution
if [ "$AUTO_EXECUTE" == "--execute" ]; then
    read -p "Execute this script? [y/N] " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        log_info "Executing script..."
        chmod +x "$TEMP_SCRIPT"
        bash "$TEMP_SCRIPT"
        log_success "Script executed successfully"
    else
        log_info "Execution cancelled"
    fi
else
    echo "To execute, run: bash $TEMP_SCRIPT"
    echo "Or re-run with: $0 $SOURCE --execute"
fi

# Cleanup
rm -f "$TEMP_SCRIPT" 2>/dev/null || true
