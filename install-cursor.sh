#!/bin/bash

# =============================================================================
# Cursor IDE Auto-Updater Installation Script
# =============================================================================
# This script installs Cursor IDE and sets up automatic updates via APT hooks
# After installation, Cursor will update automatically when you run apt upgrade

set -e  # Exit on any error
# Enable debug mode if DEBUG=1 is set
if [ "${DEBUG:-0}" = "1" ]; then
    set -x
    echo "Debug mode enabled"
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Constants
CURSOR_DIR="/usr/local/share/cursor-ai"
CURSOR_BINARY="/usr/local/bin/cursor"
VERSION_FILE="$CURSOR_DIR/version.txt"
UPDATER_SCRIPT="/usr/local/bin/update-cursor"
DESKTOP_FILE="/usr/share/applications/cursor.desktop"
APT_HOOK="/etc/apt/apt.conf.d/99-cursor-update"

# Cursor download base URL (from their download page)
CURSOR_DOWNLOAD_PAGE="https://cursor.com/download"

# Cursor icon URL
CURSOR_ICON_URL="https://cursor.com/_next/static/media/placeholder-logo.da8a9d2b.webp"

# Function to print colored output
print_status() {
    echo -e "${BLUE}[Cursor Installer]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[Cursor Installer]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[Cursor Installer]${NC} $1"
}

print_error() {
    echo -e "${RED}[Cursor Installer]${NC} $1"
}

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "This script must be run as root (use sudo)"
        exit 1
    fi
}

# Check and install dependencies
install_dependencies() {
    print_status "Checking dependencies..."
    
    local deps=("wget" "curl" "jq")
    local missing_deps=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing_deps+=("$dep")
        fi
    done
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        print_status "Installing missing dependencies: ${missing_deps[*]}"
        apt update
        apt install -y "${missing_deps[@]}"
    else
        print_success "All dependencies are already installed"
    fi
}

# Detect system architecture
detect_architecture() {
    local arch
    arch=$(uname -m)
    
    case "$arch" in
        x86_64|amd64)
            echo "x64"
            ;;
        aarch64|arm64)
            echo "arm64"
            ;;
        *)
            print_error "Unsupported architecture: $arch"
            print_error "Supported architectures: x86_64, aarch64"
            exit 1
            ;;
    esac
}

# Get the latest Cursor version from the download page
get_latest_version() {
    local response
    response=$(curl -s "$CURSOR_DOWNLOAD_PAGE" 2>/dev/null)
    if [ $? -ne 0 ]; then
        print_error "Failed to fetch version information from Cursor download page"
        exit 1
    fi
    
    # Extract version from AppImage URL pattern
    local version
    version=$(echo "$response" | grep -o 'https://downloads.cursor.com[^"]*x86_64\.AppImage' | head -1 | grep -o 'Cursor-[0-9][^-]*' | sed 's/Cursor-//' 2>/dev/null)
    if [ -z "$version" ]; then
        print_error "Failed to parse version from download page"
        exit 1
    fi
    
    echo "$version"
}

# Get download URL based on architecture
get_download_url() {
    local arch
    arch=$(detect_architecture)
    
    local response
    response=$(curl -s "$CURSOR_DOWNLOAD_PAGE" 2>/dev/null)
    if [ $? -ne 0 ]; then
        print_error "Failed to fetch download information from Cursor download page"
        exit 1
    fi
    
    local download_url
    case "$arch" in
        x64)
            download_url=$(echo "$response" | grep -o 'https://downloads.cursor.com[^"]*x86_64\.AppImage' | head -1 2>/dev/null)
            ;;
        arm64)
            download_url=$(echo "$response" | grep -o 'https://downloads.cursor.com[^"]*aarch64\.AppImage' | head -1 2>/dev/null)
            ;;
        *)
            print_error "Unsupported architecture: $arch"
            exit 1
            ;;
    esac
    
    if [ -z "$download_url" ]; then
        print_error "Failed to parse download URL for architecture: $arch"
        exit 1
    fi
    
    echo "$download_url"
}

# Get the latest Cursor version and download URL (for backward compatibility)
get_cursor_info() {
    print_status "Detecting system architecture..."
    
    local arch
    arch=$(detect_architecture)
    print_status "Detected architecture: $arch"
    
    print_status "Fetching download information..."
    
    # Get version and download URL
    local version
    local download_url
    
    version=$(get_latest_version)
    download_url=$(get_download_url)
    
    print_status "Found version: $version"
    print_status "Download URL ready"
    
    echo "$version|$download_url"
}

# Create Cursor directory
create_cursor_directory() {
    print_status "Creating Cursor directory at $CURSOR_DIR..."
    
    if [ -d "$CURSOR_DIR" ]; then
        print_warning "Directory $CURSOR_DIR already exists"
    else
        mkdir -p "$CURSOR_DIR"
        print_success "Created directory $CURSOR_DIR"
    fi
}

# Download and install Cursor
download_cursor() {
    local version="$1"
    local download_url="$2"
    
    print_status "Downloading Cursor $version..."
    
    # Backup existing installation if it exists
    if [ -f "$CURSOR_BINARY" ]; then
        print_status "Backing up existing installation..."
        mv "$CURSOR_BINARY" "$CURSOR_BINARY.backup"
    fi
    
    # Download new version
    if ! wget -O "$CURSOR_BINARY" "$download_url"; then
        print_error "Failed to download Cursor"
        # Restore backup if download failed
        if [ -f "$CURSOR_BINARY.backup" ]; then
            mv "$CURSOR_BINARY.backup" "$CURSOR_BINARY"
        fi
        exit 1
    fi
    
    # Make executable
    chmod +x "$CURSOR_BINARY"
    
    # Save version info
    echo "$version" > "$VERSION_FILE"
    
    # Remove backup on success
    if [ -f "$CURSOR_BINARY.backup" ]; then
        rm "$CURSOR_BINARY.backup"
    fi
    
    print_success "Cursor $version installed successfully"
}

# Create desktop entry
create_desktop_entry() {
    print_status "Creating desktop entry..."
    
    cat > "$DESKTOP_FILE" << EOF
[Desktop Entry]
Name=Cursor
Comment=The AI-first code editor
Exec=$CURSOR_BINARY
Icon=$CURSOR_DIR/cursor.png
Terminal=false
Type=Application
Categories=Development;TextEditor;
StartupWMClass=cursor
MimeType=text/plain;
EOF
    
    # Download icon
    print_status "Downloading Cursor icon..."
    if wget -q -O "$CURSOR_DIR/cursor.png" "$CURSOR_ICON_URL" 2>/dev/null; then
        print_success "Downloaded Cursor icon"
    else
        print_warning "Could not download icon, using default"
        # Remove icon line from desktop file if download failed
        sed -i '/^Icon=/d' "$DESKTOP_FILE"
    fi
    
    print_success "Desktop entry created at $DESKTOP_FILE"
}

# Create check-only script (for apt update)
create_check_script() {
    print_status "Creating check-only script..."
    
    cat > "/usr/local/bin/check-cursor-update" << 'EOF'
#!/bin/bash

# Cursor IDE Check-Only Script
# This script only checks for updates without downloading (for apt update)

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Constants
CURSOR_DIR="/usr/local/share/cursor-ai"
CURSOR_BINARY="/usr/local/bin/cursor"
VERSION_FILE="$CURSOR_DIR/version.txt"

# Cursor download page URL
CURSOR_DOWNLOAD_PAGE="https://cursor.com/download"

print_status() {
    echo -e "${BLUE}[Cursor Check]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[Cursor Check]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[Cursor Check]${NC} $1"
}

print_error() {
    echo -e "${RED}[Cursor Check]${NC} $1"
}

# Detect architecture
detect_architecture() {
    local arch
    arch=$(uname -m)
    
    case "$arch" in
        x86_64)
            echo "x64"
            ;;
        aarch64|arm64)
            echo "arm64"
            ;;
        *)
            echo "unsupported"
            ;;
    esac
}

# Get latest version from download page
get_latest_cursor_version() {
    local response
    response=$(curl -s "$CURSOR_DOWNLOAD_PAGE" 2>/dev/null)
    if [ $? -ne 0 ]; then
        print_error "Failed to fetch version information from Cursor download page"
        return 1
    fi
    
    # Extract version from AppImage URL pattern
    local version
    version=$(echo "$response" | grep -o 'https://downloads.cursor.com[^"]*x86_64\.AppImage' | head -1 | grep -o 'Cursor-[0-9][^-]*' | sed 's/Cursor-//' 2>/dev/null)
    if [ -z "$version" ]; then
        print_error "Failed to parse version from download page"
        return 1
    fi
    
    echo "$version"
}

# Check if Cursor is installed
if [ ! -f "$CURSOR_BINARY" ]; then
    print_warning "Cursor is not installed, skipping update check"
    exit 0
fi

# Get current version
current_version=""
if [ -f "$VERSION_FILE" ]; then
    current_version=$(cat "$VERSION_FILE")
fi

print_status "Checking for Cursor updates..."
print_status "Current version: ${current_version:-unknown}"

# Get latest version from API
latest_version=$(get_latest_cursor_version)
if [ $? -ne 0 ] || [ -z "$latest_version" ]; then
    print_error "Failed to check for updates"
    exit 0  # Don't fail the apt update
fi

print_status "Latest version: $latest_version"

# Compare versions
if [ "$current_version" = "$latest_version" ]; then
    print_status "Cursor is up to date"
    exit 0
fi

print_status "New version available: ${current_version:-unknown} → $latest_version"
print_status "Run 'sudo update-cursor' to install the update"
EOF

    chmod +x "/usr/local/bin/check-cursor-update"
    print_success "Check-only script created"
}

# Create updater script
create_updater_script() {
    print_status "Creating updater script..."
    
    cat > "$UPDATER_SCRIPT" << 'EOF'
#!/bin/bash

# Cursor IDE Auto-Updater Script
# This script is called automatically after apt upgrade

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Constants
CURSOR_DIR="/usr/local/share/cursor-ai"
CURSOR_BINARY="/usr/local/bin/cursor"
VERSION_FILE="$CURSOR_DIR/version.txt"

# Cursor download page URL
CURSOR_DOWNLOAD_PAGE="https://cursor.com/download"

print_status() {
    echo -e "${BLUE}[Cursor Updater]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[Cursor Updater]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[Cursor Updater]${NC} $1"
}

print_error() {
    echo -e "${RED}[Cursor Updater]${NC} $1"
}

# Detect architecture
detect_architecture() {
    local arch
    arch=$(uname -m)
    
    case "$arch" in
        x86_64)
            echo "x64"
            ;;
        aarch64|arm64)
            echo "arm64"
            ;;
        *)
            echo "unsupported"
            ;;
    esac
}

# Get download URL based on architecture
get_download_url() {
    local arch
    arch=$(detect_architecture)
    
    local response
    response=$(curl -s "$CURSOR_DOWNLOAD_PAGE" 2>/dev/null)
    if [ $? -ne 0 ]; then
        print_error "Failed to fetch download information from Cursor download page"
        return 1
    fi
    
    local download_url
    case "$arch" in
        x64)
            download_url=$(echo "$response" | grep -o 'https://downloads.cursor.com[^"]*x86_64\.AppImage' | head -1 2>/dev/null)
            ;;
        arm64)
            download_url=$(echo "$response" | grep -o 'https://downloads.cursor.com[^"]*aarch64\.AppImage' | head -1 2>/dev/null)
            ;;
        *)
            print_error "Unsupported architecture: $arch"
            exit 1
            ;;
    esac
    
    if [ -z "$download_url" ]; then
        print_error "Failed to parse download URL for architecture: $arch"
        return 1
    fi
    
    echo "$download_url"
}

# Get latest version from download page
get_latest_cursor_version() {
    local response
    response=$(curl -s "$CURSOR_DOWNLOAD_PAGE" 2>/dev/null)
    if [ $? -ne 0 ]; then
        print_error "Failed to fetch version information from Cursor download page"
        return 1
    fi
    
    # Extract version from AppImage URL pattern
    local version
    version=$(echo "$response" | grep -o 'https://downloads.cursor.com[^"]*x86_64\.AppImage' | head -1 | grep -o 'Cursor-[0-9][^-]*' | sed 's/Cursor-//' 2>/dev/null)
    if [ -z "$version" ]; then
        print_error "Failed to parse version from download page"
        return 1
    fi
    
    echo "$version"
}

# Check if Cursor is installed
if [ ! -f "$CURSOR_BINARY" ]; then
    print_warning "Cursor is not installed, skipping update check"
    exit 0
fi

# Get current version
current_version=""
if [ -f "$VERSION_FILE" ]; then
    current_version=$(cat "$VERSION_FILE")
fi

print_status "Checking for Cursor updates..."
print_status "Current version: ${current_version:-unknown}"

# Get latest version from API
latest_version=$(get_latest_cursor_version)
if [ $? -ne 0 ] || [ -z "$latest_version" ]; then
    print_error "Failed to check for updates"
    exit 0  # Don't fail the apt upgrade
fi

print_status "Latest version: $latest_version"

# Compare versions
if [ "$current_version" = "$latest_version" ]; then
    print_status "Cursor is up to date"
    exit 0
fi

print_status "New version available: ${current_version:-unknown} → $latest_version"
print_status "Downloading update..."

# Get download URL
download_url=$(get_download_url)
if [ $? -ne 0 ] || [ -z "$download_url" ]; then
    print_error "Failed to get download URL"
    exit 0
fi

# Backup current installation
if [ -f "$CURSOR_BINARY" ]; then
    cp "$CURSOR_BINARY" "$CURSOR_BINARY.backup"
fi

# Download new version
temp_file=$(mktemp)
if ! curl -L -o "$temp_file" "$download_url"; then
    print_error "Failed to download update"
    rm -f "$temp_file"
    # Restore backup if it exists
    if [ -f "$CURSOR_BINARY.backup" ]; then
        mv "$CURSOR_BINARY.backup" "$CURSOR_BINARY"
    fi
    exit 1
fi

# Replace the binary
mv "$temp_file" "$CURSOR_BINARY"
chmod +x "$CURSOR_BINARY"

# Update version file
echo "$latest_version" > "$VERSION_FILE"

# Remove backup on success
if [ -f "$CURSOR_BINARY.backup" ]; then
    rm "$CURSOR_BINARY.backup"
fi

print_success "Cursor updated to version $latest_version"
EOF

    chmod +x "$UPDATER_SCRIPT"
    print_success "Updater script created"
}

# Create APT hook
create_apt_hook() {
    print_status "Creating APT hook..."
    
    cat > "$APT_HOOK" << EOF
// Cursor IDE Auto-Updater APT Hook
// This mimics the behavior of other packages: apt update only checks for updates
// Run check-only script after apt update (only check, don't download)
APT::Update::Post-Invoke {"if [ -f /usr/local/bin/check-cursor-update ]; then /usr/local/bin/check-cursor-update || true; fi";};
EOF
    
    print_success "APT hook created at $APT_HOOK"
}

# Test network connectivity
test_connectivity() {
    print_status "Testing network connectivity..."
    
    # Test basic internet connectivity
    if ! curl -s --connect-timeout 10 "https://www.google.com" > /dev/null; then
        print_error "No internet connectivity detected"
        print_error "Please check your internet connection and try again"
        exit 1
    fi
    
    # Test Cursor API connectivity
    if ! curl -s --connect-timeout 10 "https://cursor.com" > /dev/null; then
        print_error "Cannot reach Cursor website"
        print_error "Please check if cursor.com is accessible from your network"
        exit 1
    fi
    
    print_success "Network connectivity test passed"
}

# Helper: add --no-sandbox flag to desktop entry if not already present
update_desktop_entry_no_sandbox() {
    if [[ -f "$DESKTOP_FILE" ]]; then
        if grep -q "--no-sandbox" "$DESKTOP_FILE"; then
            print_status "Desktop entry already contains --no-sandbox flag"
        else
            print_status "Adding --no-sandbox flag to desktop entry ($DESKTOP_FILE)"
            sed -i "s|Exec=$CURSOR_BINARY|Exec=$CURSOR_BINARY --no-sandbox|g" "$DESKTOP_FILE"
            print_success "Updated desktop entry with --no-sandbox flag"
        fi
    else
        print_warning "Desktop entry not found yet – cannot apply --no-sandbox fix"
    fi
}

# Detect and fix common launch issues that prevent the Cursor AppImage from
# starting on some systems (missing FUSE library and sandbox namespace error).
# This check is executed ONCE during installation so it has zero runtime cost
# on every subsequent launch.
detect_and_fix_launch_issues() {
    print_status "Performing one-time check for common launch issues..."

    # ---------------------------------------------------------------------
    # 1. FUSE library missing (AppImage fails with: "dlopen(): error loading libfuse.so.2")
    # ---------------------------------------------------------------------
    if ! ldconfig -p | grep -q "libfuse\.so\.2"; then
        print_warning "FUSE library (libfuse.so.2) not found. Installing libfuse2..."
        # Refresh package lists in case they are stale
        apt-get update -y
        if apt-get install -y libfuse2 > /dev/null 2>&1; then
            print_success "libfuse2 installed successfully"
        else
            print_error "Failed to install libfuse2 automatically. Please install it manually if the AppImage fails to start."
        fi
    else
        print_success "FUSE library detected – no action required"
    fi

    # ---------------------------------------------------------------------
    # 2. Sandbox namespace error (Electron fails with: "Failed to move to new namespace")
    # ---------------------------------------------------------------------
    local clone_flag
    clone_flag=$(sysctl -n kernel.unprivileged_userns_clone 2>/dev/null || echo 1)
    if [ "$clone_flag" = "0" ]; then
        print_warning "kernel.unprivileged_userns_clone is disabled. Enabling to avoid Electron sandbox errors..."
        if sysctl -w kernel.unprivileged_userns_clone=1 > /dev/null 2>&1; then
            echo "kernel.unprivileged_userns_clone=1" > /etc/sysctl.d/60-cursor-unprivileged-userns.conf
            sysctl --system > /dev/null 2>&1
            print_success "Enabled unprivileged user namespace cloning"
        else
            print_error "Failed to modify kernel.unprivileged_userns_clone. You may need to enable it manually if Cursor fails to start."
        fi
    else
        print_success "kernel.unprivileged_userns_clone already enabled – no action required"
    fi

    # ---------------------------------------------------------------------
    # 3. Detect runtime sandbox failures and apply --no-sandbox fallback
    # ---------------------------------------------------------------------
    print_status "Verifying Cursor binary can run headless (sandbox check)..."

    local launch_output
    if launch_output=$("$CURSOR_BINARY" --version 2>&1); then
        print_success "Cursor reported version successfully → sandbox OK"
    else
        # Capture known sandbox error keywords (extended list)
        if echo "$launch_output" | grep -Eiq "setuid sandbox|Failed to move to new namespace|zygote_host_impl_linux|Check failed|Running as root without --no-sandbox"; then
            print_warning "Sandbox-related launch issue detected"
            update_desktop_entry_no_sandbox
        else
            print_warning "Cursor failed to run (exit code $launch_status). Unknown reason; skipping --no-sandbox workaround."
        fi
    fi
}

# Main installation function
main() {
    print_status "Starting Cursor IDE installation with auto-updater..."
    
    print_status "Step 1/9: Checking root privileges..."
    check_root
    print_success "Root check passed"
    
    print_status "Step 2/9: Installing dependencies..."
    install_dependencies
    print_success "Dependencies check completed"
    
    print_status "Step 3/9: Testing network connectivity..."
    test_connectivity
    print_success "Network test completed"
    
    print_status "Step 4/9: Fetching latest version information..."
    local version
    version=$(get_latest_version)
    print_success "Latest version: $version"
    
    print_status "Step 5/9: Getting download URL..."
    local download_url
    download_url=$(get_download_url)
    print_success "Download URL obtained"
    
    print_status "Step 6/9: Setting up directory structure..."
    create_cursor_directory
    download_cursor "$version" "$download_url"
    print_success "Cursor installation completed"

    print_status "Step 7/9: Creating desktop integration..."
    create_desktop_entry
    print_success "Desktop entry created"

    print_status "Step 8/9: Checking for launch issues (one-time)..."
    detect_and_fix_launch_issues
    print_success "Launch issue check completed"

    print_status "Step 9/9: Setting up auto-updater..."
    create_check_script
    create_updater_script
    create_apt_hook
    print_success "Auto-updater configured"
    
    print_success ""
    print_success "Installation complete!"
    print_success ""
    print_success "Cursor IDE has been installed and configured for automatic updates."
    print_success ""
    print_success "What's next:"
    print_success "  • Launch Cursor from your application menu"
    print_success "  • Run 'sudo apt update' to check for updates"
    print_success "  • Run 'sudo update-cursor' to download and install updates"
    print_success "  • Current version: $version"
    print_success ""
    print_status "You can manually check for updates anytime by running: sudo check-cursor-update"
    print_status "You can manually update anytime by running: sudo update-cursor"
}

# Run main function
main "$@"
