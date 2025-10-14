#!/bin/bash

# Debug version of install-cursor.sh to troubleshoot issues

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_debug() {
    echo -e "${YELLOW}[DEBUG]${NC} $1"
}

print_status() {
    echo -e "${BLUE}[Cursor Installer]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[Cursor Installer]${NC} $1"
}

print_error() {
    echo -e "${RED}[Cursor Installer]${NC} $1"
}

# Debug function to check each step
debug_installation() {
    print_debug "Starting debug mode..."
    
    # Check if running as root
    print_debug "Checking root privileges..."
    if [[ $EUID -ne 0 ]]; then
        print_error "This script must be run as root (use sudo)"
        exit 1
    fi
    print_success "Root check passed"
    
    # Check dependencies
    print_debug "Checking dependencies..."
    local deps=("wget" "curl" "jq")
    for dep in "${deps[@]}"; do
        if command -v "$dep" &> /dev/null; then
            print_success "$dep is installed"
        else
            print_error "$dep is missing"
        fi
    done
    
    # Test network connectivity
    print_debug "Testing basic internet connectivity..."
    if curl -s --connect-timeout 5 "https://www.google.com" > /dev/null; then
        print_success "Internet connectivity: OK"
    else
        print_error "Internet connectivity: FAILED"
        return 1
    fi
    
    # Test Cursor API connectivity and URLs
    print_debug "Testing Cursor API (stable track)..."
    local base_api="https://cursor.com/api/download"

    # Helper to test a platform via API
    test_platform_api() {
        local platform="$1"
        print_debug "Testing platform: $platform"
        local json
        if ! json=$(curl -fsSL --connect-timeout 10 "${base_api}?platform=${platform}&releaseTrack=stable" 2>&1); then
            print_error "API request failed for ${platform}"
            print_debug "curl error: $json"
            return 1
        fi
        local version
        local url
        version=$(echo "$json" | jq -r '.version // empty')
        url=$(echo "$json" | jq -r '.downloadUrl // empty')
        if [ -z "$version" ]; then
            print_error "Missing version in API response for ${platform}"
        else
            print_success "${platform} version: $version"
        fi
        if [ -z "$url" ]; then
            print_error "Missing downloadUrl in API response for ${platform}"
            return 1
        fi
        print_success "${platform} download URL received"
        print_debug "${platform} URL: ${url:0:80}..."
        if curl -s -I --connect-timeout 10 "$url" | head -1 | grep -q "200"; then
            print_success "${platform} AppImage is accessible"
        else
            print_error "${platform} AppImage not accessible"
        fi
    }

    test_platform_api "linux-x64"
    test_platform_api "linux-arm64"
    
    print_success "Debug check completed successfully"
}

# Run debug
debug_installation
