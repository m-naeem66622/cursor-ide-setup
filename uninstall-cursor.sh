#!/bin/bash

# =============================================================================
# Cursor IDE Uninstaller Script
# =============================================================================
# This script removes Cursor IDE and all associated files

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Constants
CURSOR_DIR="/opt/cursor-ai"
UPDATER_SCRIPT="/usr/local/bin/update-cursor"
DESKTOP_FILE="/usr/share/applications/cursor.desktop"
APT_HOOK="/etc/apt/apt.conf.d/99-cursor-update"

print_status() {
    echo -e "${BLUE}[Cursor Uninstaller]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[Cursor Uninstaller]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[Cursor Uninstaller]${NC} $1"
}

print_error() {
    echo -e "${RED}[Cursor Uninstaller]${NC} $1"
}

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "This script must be run as root (use sudo)"
        exit 1
    fi
}

# Remove files
remove_files() {
    local removed_count=0
    
    # Remove Cursor directory
    if [ -d "$CURSOR_DIR" ]; then
        print_status "Removing Cursor directory: $CURSOR_DIR"
        rm -rf "$CURSOR_DIR"
        removed_count=$((removed_count + 1))
        print_success "Cursor directory removed"
    fi
    
    # Remove updater script
    if [ -f "$UPDATER_SCRIPT" ]; then
        print_status "Removing updater script: $UPDATER_SCRIPT"
        rm -f "$UPDATER_SCRIPT"
        removed_count=$((removed_count + 1))
        print_success "Updater script removed"
    fi
    
    # Remove desktop file
    if [ -f "$DESKTOP_FILE" ]; then
        print_status "Removing desktop entry: $DESKTOP_FILE"
        rm -f "$DESKTOP_FILE"
        removed_count=$((removed_count + 1))
        print_success "Desktop entry removed"
    fi
    
    # Remove APT hook
    if [ -f "$APT_HOOK" ]; then
        print_status "Removing APT hook: $APT_HOOK"
        rm -f "$APT_HOOK"
        removed_count=$((removed_count + 1))
        print_success "APT hook removed"
    fi
    
    if [ $removed_count -eq 0 ]; then
        print_warning "No Cursor installation found"
    else
        print_success "Successfully removed $removed_count component(s)"
    fi
}

main() {
    print_status "Starting Cursor IDE uninstallation..."
    
    check_root
    
    # Confirm with user
    echo
    print_warning "This will completely remove Cursor IDE and all associated files."
    read -p "Are you sure you want to continue? [y/N]: " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Uninstallation cancelled"
        exit 0
    fi
    
    remove_files
    
    print_success ""
    print_success "Cursor IDE has been completely uninstalled."
    print_success "You may need to refresh your application menu to remove the Cursor entry."
}

main "$@"
