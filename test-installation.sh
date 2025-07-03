#!/bin/bash

# =============================================================================
# Cursor IDE Installation Test Script
# =============================================================================
# This script tests if Cursor IDE is properly installed and configured

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Constants
CURSOR_DIR="/opt/cursor-ai"
CURSOR_BINARY="$CURSOR_DIR/cursor"
VERSION_FILE="$CURSOR_DIR/version.txt"
UPDATER_SCRIPT="/usr/local/bin/update-cursor"
DESKTOP_FILE="/usr/share/applications/cursor.desktop"
APT_HOOK="/etc/apt/apt.conf.d/99-cursor-update"

print_test() {
    echo -e "${BLUE}[Test]${NC} $1"
}

print_pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
}

print_fail() {
    echo -e "${RED}[FAIL]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# Test functions
test_cursor_binary() {
    print_test "Checking Cursor binary..."
    
    if [ -f "$CURSOR_BINARY" ]; then
        if [ -x "$CURSOR_BINARY" ]; then
            print_pass "Cursor binary exists and is executable"
            return 0
        else
            print_fail "Cursor binary exists but is not executable"
            return 1
        fi
    else
        print_fail "Cursor binary not found at $CURSOR_BINARY"
        return 1
    fi
}

test_version_file() {
    print_test "Checking version file..."
    
    if [ -f "$VERSION_FILE" ]; then
        local version
        version=$(cat "$VERSION_FILE")
        if [ -n "$version" ]; then
            print_pass "Version file exists with version: $version"
            return 0
        else
            print_fail "Version file exists but is empty"
            return 1
        fi
    else
        print_fail "Version file not found at $VERSION_FILE"
        return 1
    fi
}

test_updater_script() {
    print_test "Checking updater script..."
    
    if [ -f "$UPDATER_SCRIPT" ]; then
        if [ -x "$UPDATER_SCRIPT" ]; then
            print_pass "Updater script exists and is executable"
            return 0
        else
            print_fail "Updater script exists but is not executable"
            return 1
        fi
    else
        print_fail "Updater script not found at $UPDATER_SCRIPT"
        return 1
    fi
}

test_desktop_file() {
    print_test "Checking desktop file..."
    
    if [ -f "$DESKTOP_FILE" ]; then
        # Check if it has the required fields
        if grep -q "Name=Cursor" "$DESKTOP_FILE" && \
           grep -q "Exec=$CURSOR_BINARY" "$DESKTOP_FILE"; then
            print_pass "Desktop file exists with correct content"
            return 0
        else
            print_fail "Desktop file exists but has incorrect content"
            return 1
        fi
    else
        print_fail "Desktop file not found at $DESKTOP_FILE"
        return 1
    fi
}

test_apt_hook() {
    print_test "Checking APT hook..."
    
    if [ -f "$APT_HOOK" ]; then
        if grep -q "update-cursor" "$APT_HOOK"; then
            print_pass "APT hook exists and references updater script"
            return 0
        else
            print_fail "APT hook exists but doesn't reference updater script"
            return 1
        fi
    else
        print_fail "APT hook not found at $APT_HOOK"
        return 1
    fi
}

test_dependencies() {
    print_test "Checking dependencies..."
    
    local deps=("wget" "curl" "jq")
    local missing_deps=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing_deps+=("$dep")
        fi
    done
    
    if [ ${#missing_deps[@]} -eq 0 ]; then
        print_pass "All dependencies are installed: ${deps[*]}"
        return 0
    else
        print_fail "Missing dependencies: ${missing_deps[*]}"
        return 1
    fi
}

test_updater_functionality() {
    print_test "Testing updater functionality (dry run)..."
    
    if [ ! -f "$UPDATER_SCRIPT" ]; then
        print_fail "Updater script not found, skipping functionality test"
        return 1
    fi
    
    # Test network connectivity to GitHub API
    if curl -s "https://api.github.com/repos/getcursor/cursor/releases/latest" > /dev/null; then
        print_pass "Network connectivity to GitHub API is working"
        return 0
    else
        print_warn "Cannot reach GitHub API (network issue or rate limit)"
        return 1
    fi
}

# Main test function
main() {
    echo "========================================"
    echo "  Cursor IDE Installation Test Suite"
    echo "========================================"
    echo
    
    local tests=(
        "test_dependencies"
        "test_cursor_binary" 
        "test_version_file"
        "test_updater_script"
        "test_desktop_file"
        "test_apt_hook"
        "test_updater_functionality"
    )
    
    local passed=0
    local failed=0
    local total=${#tests[@]}
    
    for test in "${tests[@]}"; do
        if $test; then
            ((passed++))
        else
            ((failed++))
        fi
        echo
    done
    
    echo "========================================"
    echo "  Test Results"
    echo "========================================"
    echo -e "Total tests: $total"
    echo -e "Passed: ${GREEN}$passed${NC}"
    echo -e "Failed: ${RED}$failed${NC}"
    echo
    
    if [ $failed -eq 0 ]; then
        print_pass "All tests passed! Cursor IDE is properly installed."
        echo
        print_test "You can now:"
        echo "  • Launch Cursor from your application menu"
        echo "  • Run 'sudo apt upgrade' to test automatic updates"
        echo "  • Run 'sudo update-cursor' to manually check for updates"
        exit 0
    else
        print_fail "Some tests failed. Please check the installation."
        echo
        print_test "To reinstall, run:"
        echo "  sudo ./install-cursor.sh"
        exit 1
    fi
}

main "$@"
