#!/bin/bash
# E2E Autoinstall Test Runner
# Runs packer build on target VM and sets up VNC for monitoring

set -e

# Configuration
TARGET_VM="${TARGET_VM:-davidlay@10.1.21.29}"
WORK_DIR="${WORK_DIR:-~/autoinstall-e2e-test}"
AUTOINSTALL_FILE="${1:-autoinstall.yaml}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info() { echo -e "${CYAN}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Parse arguments
ACTION="${2:-run}"  # run, vnc, logs, status, stop

show_help() {
    echo "Usage: $0 [autoinstall.yaml] [action]"
    echo ""
    echo "Actions:"
    echo "  run     - Start new packer build (default)"
    echo "  vnc     - Connect VNC to existing build"
    echo "  logs    - Tail packer logs"
    echo "  console - View QEMU serial console output"
    echo "  status  - Check build status"
    echo "  stop    - Stop running build"
    echo ""
    echo "Examples:"
    echo "  $0                          # Run with default autoinstall.yaml"
    echo "  $0 my-autoinstall.yaml      # Run with custom autoinstall"
    echo "  $0 autoinstall.yaml vnc     # Just connect VNC"
    echo "  $0 autoinstall.yaml console # View serial console"
    echo "  $0 autoinstall.yaml logs    # Just tail logs"
}

stop_build() {
    log_info "Stopping any running packer/qemu processes..."
    ssh "$TARGET_VM" "pkill -9 packer 2>/dev/null; pkill -9 qemu 2>/dev/null" || true
    log_success "Build stopped"
}

get_vnc_port() {
    ssh "$TARGET_VM" "grep 'vnc://' /tmp/packer.log 2>/dev/null | tail -1 | sed 's/.*vnc:\/\/127.0.0.1://' | tr -d ' '"
}

setup_vnc() {
    local port="$1"
    if [ -z "$port" ]; then
        log_error "No VNC port found. Is the build running?"
        return 1
    fi
    
    log_info "Setting up SSH tunnel to VNC port $port..."
    pkill -f "ssh.*-L.*:127.0.0.1:$port" 2>/dev/null || true
    ssh -f -N -L "$port:127.0.0.1:$port" "$TARGET_VM"
    log_success "SSH tunnel established on localhost:$port"
    
    log_info "Launching VNC viewer..."
    pkill vncviewer 2>/dev/null || true
    export DISPLAY=:0
    vncviewer "localhost:$port" &
    log_success "VNC viewer launched (PID: $!)"
}

show_logs() {
    log_info "Tailing packer logs (Ctrl+C to exit)..."
    ssh "$TARGET_VM" "tail -f /tmp/packer.log"
}

show_console() {
    local lines="${3:-50}"  # Default 50 lines, can override with 3rd arg
    log_info "QEMU Serial Console Output (last $lines lines):"
    echo ""
    ssh "$TARGET_VM" "tail -$lines /tmp/qemu-console.log 2>/dev/null" || log_warn "No console output available"
}

tail_console() {
    log_info "Tailing QEMU serial console (Ctrl+C to exit)..."
    ssh "$TARGET_VM" "tail -f /tmp/qemu-console.log"
}

check_status() {
    log_info "Checking build status..."
    
    # Check if processes are running
    local packer_running=$(ssh "$TARGET_VM" "pgrep -x packer" 2>/dev/null || echo "")
    local qemu_running=$(ssh "$TARGET_VM" "pgrep -f qemu-system" 2>/dev/null || echo "")
    
    if [ -n "$packer_running" ]; then
        log_success "Packer is running (PID: $packer_running)"
    else
        log_warn "Packer is NOT running"
    fi
    
    if [ -n "$qemu_running" ]; then
        log_success "QEMU VM is running (PID: $qemu_running)"
        local vnc_port=$(get_vnc_port)
        [ -n "$vnc_port" ] && log_info "VNC port: $vnc_port"
    else
        log_warn "QEMU VM is NOT running"
    fi
    
    # Show last few log lines
    echo ""
    log_info "Last 10 log lines:"
    ssh "$TARGET_VM" "tail -10 /tmp/packer.log 2>/dev/null" || log_warn "No logs available"
}

run_build() {
    log_info "Starting E2E Autoinstall Test..."
    log_info "Target VM: $TARGET_VM"
    log_info "Work dir: $WORK_DIR"
    log_info "Autoinstall file: $AUTOINSTALL_FILE"
    echo ""
    
    # Stop any existing build
    stop_build
    
    # Clean up output directory
    log_info "Cleaning up previous build artifacts..."
    ssh "$TARGET_VM" "cd $WORK_DIR && rm -rf output-* 2>/dev/null" || true
    
    # Start packer build
    log_info "Starting packer build..."
    ssh "$TARGET_VM" "cd $WORK_DIR && nohup sg kvm -c 'packer build -var autoinstall_path=$AUTOINSTALL_FILE .' > /tmp/packer.log 2>&1 &"
    
    # Wait for VM to start and get VNC port
    log_info "Waiting for VM to start..."
    sleep 15
    
    local vnc_port=$(get_vnc_port)
    if [ -z "$vnc_port" ]; then
        log_error "Failed to get VNC port. Check logs with: $0 $AUTOINSTALL_FILE logs"
        return 1
    fi
    
    log_success "VM started! VNC port: $vnc_port"
    
    # Setup VNC
    setup_vnc "$vnc_port"
    
    echo ""
    log_success "Build started successfully!"
    echo ""
    echo "Useful commands:"
    echo "  $0 $AUTOINSTALL_FILE logs    # Tail packer logs"
    echo "  $0 $AUTOINSTALL_FILE console # View serial console output"
    echo "  $0 $AUTOINSTALL_FILE status  # Check build status"
    echo "  $0 $AUTOINSTALL_FILE vnc     # Reconnect VNC"
    echo "  $0 $AUTOINSTALL_FILE stop    # Stop the build"
}

# Main
case "$ACTION" in
    run)
        run_build
        ;;
    vnc)
        vnc_port=$(get_vnc_port)
        setup_vnc "$vnc_port"
        ;;
    logs)
        show_logs
        ;;
    status)
        check_status
        ;;
    stop)
        stop_build
        ;;
    console)
        show_console
        ;;
    console-tail)
        tail_console
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        log_error "Unknown action: $ACTION"
        show_help
        exit 1
        ;;
esac
