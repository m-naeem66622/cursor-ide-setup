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
    
    # Test Cursor website connectivity
    print_debug "Testing Cursor website connectivity..."
    if curl -s --connect-timeout 5 "https://cursor.com" > /dev/null; then
        print_success "Cursor website connectivity: OK"
    else
        print_error "Cursor website connectivity: FAILED"
        return 1
    fi
    
    # Test Cursor API for downloads
    print_debug "Testing Cursor download API..."
    local CURSOR_API_BASE="https://cursor.com/api/download"
    local CURSOR_LINUX_X64_URL="$CURSOR_API_BASE?platform=linux-x64&releaseTrack=stable"
    local CURSOR_LINUX_ARM64_URL="$CURSOR_API_BASE?platform=linux-arm64&releaseTrack=stable"
    
    # Test x64 download URL
    print_debug "Testing x64 download URL..."
    local response
    if response=$(curl -s --connect-timeout 10 "$CURSOR_LINUX_X64_URL" 2>&1); then
        print_success "x64 API response received"
        
        # Try to parse JSON
        if command -v jq &> /dev/null; then
            local version=$(echo "$response" | jq -r '.version' 2>/dev/null)
            local download_url=$(echo "$response" | jq -r '.downloadUrl' 2>/dev/null)
            
            if [ "$version" != "null" ] && [ -n "$version" ]; then
                print_success "x64 version: $version"
            else
                print_error "Could not parse version from x64 response"
            fi
            
            if [ "$download_url" != "null" ] && [ -n "$download_url" ]; then
                print_success "x64 download URL found"
                print_debug "x64 URL: ${download_url:0:60}..."
                
                # Test the actual download URL
                if curl -s -I --connect-timeout 10 "$download_url" | head -1 | grep -q "200"; then
                    print_success "x64 AppImage file is accessible"
                else
                    print_error "x64 AppImage file is not accessible"
                fi
            else
                print_error "Could not parse download URL from x64 response"
            fi
        else
            print_error "jq is required to parse API response"
        fi
    else
        print_error "Failed to fetch x64 API response"
        print_debug "curl error: $response"
    fi
    
    # Test arm64 download URL
    print_debug "Testing arm64 download URL..."
    if response=$(curl -s --connect-timeout 10 "$CURSOR_LINUX_ARM64_URL" 2>&1); then
        print_success "arm64 API response received"
        
        # Try to parse JSON
        if command -v jq &> /dev/null; then
            local version=$(echo "$response" | jq -r '.version' 2>/dev/null)
            local download_url=$(echo "$response" | jq -r '.downloadUrl' 2>/dev/null)
            
            if [ "$version" != "null" ] && [ -n "$version" ]; then
                print_success "arm64 version: $version"
            else
                print_error "Could not parse version from arm64 response"
            fi
            
            if [ "$download_url" != "null" ] && [ -n "$download_url" ]; then
                print_success "arm64 download URL found"
                print_debug "arm64 URL: ${download_url:0:60}..."
                
                # Test the actual download URL
                if curl -s -I --connect-timeout 10 "$download_url" | head -1 | grep -q "200"; then
                    print_success "arm64 AppImage file is accessible"
                else
                    print_error "arm64 AppImage file is not accessible"
                fi
            else
                print_error "Could not parse download URL from arm64 response"
            fi
        fi
    else
        print_error "Failed to fetch arm64 API response"
        print_debug "curl error: $response"
    fi
    
    print_success "Debug check completed successfully"
}

# Run debug
debug_installation
