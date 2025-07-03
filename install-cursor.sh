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
CURSOR_DIR="/opt/cursor-ai"
CURSOR_BINARY="$CURSOR_DIR/cursor"
VERSION_FILE="$CURSOR_DIR/version.txt"
UPDATER_SCRIPT="/usr/local/bin/update-cursor"
DESKTOP_FILE="/usr/share/applications/cursor.desktop"
APT_HOOK="/etc/apt/apt.conf.d/99-cursor-update"

# Cursor download URLs (from their official API)
CURSOR_API_BASE="https://cursor.com/api/download"
CURSOR_LINUX_X64_URL="$CURSOR_API_BASE?platform=linux-x64&releaseTrack=stable"
CURSOR_LINUX_ARM64_URL="$CURSOR_API_BASE?platform=linux-arm64&releaseTrack=stable"

# Cursor icon URL
CURSOR_ICON_URL="https://us1.discourse-cdn.com/flex020/uploads/cursor1/original/2X/a/a4f78589d63edd61a2843306f8e11bad9590f0ca.png"

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

# Get the latest Cursor version from the API
get_latest_version() {
    local arch
    arch=$(detect_architecture)
    
    local api_url
    case "$arch" in
        x64)
            api_url="$CURSOR_LINUX_X64_URL"
            ;;
        arm64)
            api_url="$CURSOR_LINUX_ARM64_URL"
            ;;
        *)
            print_error "Unsupported architecture: $arch"
            exit 1
            ;;
    esac
    
    local response
    response=$(curl -s "$api_url" 2>/dev/null)
    if [ $? -ne 0 ]; then
        print_error "Failed to fetch version information from Cursor API"
        exit 1
    fi
    
    local version
    version=$(echo "$response" | jq -r '.version' 2>/dev/null)
    if [ "$version" = "null" ] || [ -z "$version" ]; then
        print_error "Failed to parse version from API response"
        exit 1
    fi
    
    echo "$version"
}

# Get download URL based on architecture
get_download_url() {
    local arch
    arch=$(detect_architecture)
    
    local api_url
    case "$arch" in
        x64)
            api_url="$CURSOR_LINUX_X64_URL"
            ;;
        arm64)
            api_url="$CURSOR_LINUX_ARM64_URL"
            ;;
        *)
            print_error "Unsupported architecture: $arch"
            exit 1
            ;;
    esac
    
    local response
    response=$(curl -s "$api_url" 2>/dev/null)
    if [ $? -ne 0 ]; then
        print_error "Failed to fetch download information from Cursor API"
        exit 1
    fi
    
    local download_url
    download_url=$(echo "$response" | jq -r '.downloadUrl' 2>/dev/null)
    if [ "$download_url" = "null" ] || [ -z "$download_url" ]; then
        print_error "Failed to parse download URL from API response"
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
    
    # Get the appropriate download URL
    local download_url
    case "$arch" in
        x64)
            download_url="$CURSOR_LINUX_X64_URL"
            ;;
        arm64)
            download_url="$CURSOR_LINUX_ARM64_URL"
            ;;
        *)
            print_error "Unsupported architecture: $arch"
            exit 1
            ;;
    esac
    
    print_status "Download URL ready"
    
    # Use timestamp as version since we don't have a direct version API
    local version
    version=$(get_latest_version)
    
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
CURSOR_DIR="/opt/cursor-ai"
CURSOR_BINARY="$CURSOR_DIR/cursor"
VERSION_FILE="$CURSOR_DIR/version.txt"

# Cursor download URLs (from their official API)
CURSOR_API_BASE="https://cursor.com/api/download"
CURSOR_LINUX_X64_URL="$CURSOR_API_BASE?platform=linux-x64&releaseTrack=stable"
CURSOR_LINUX_ARM64_URL="$CURSOR_API_BASE?platform=linux-arm64&releaseTrack=stable"

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
    
    local api_url
    case "$arch" in
        x64)
            api_url="$CURSOR_LINUX_X64_URL"
            ;;
        arm64)
            api_url="$CURSOR_LINUX_ARM64_URL"
            ;;
        *)
            print_error "Unsupported architecture: $arch"
            exit 1
            ;;
    esac
    
    local response
    response=$(curl -s "$api_url" 2>/dev/null)
    if [ $? -ne 0 ]; then
        print_error "Failed to fetch download information from Cursor API"
        return 1
    fi
    
    local download_url
    download_url=$(echo "$response" | jq -r '.downloadUrl' 2>/dev/null)
    if [ "$download_url" = "null" ] || [ -z "$download_url" ]; then
        print_error "Failed to parse download URL from API response"
        return 1
    fi
    
    echo "$download_url"
}

# Get latest version from API
get_latest_cursor_version() {
    local arch
    arch=$(detect_architecture)
    
    local api_url
    case "$arch" in
        x64)
            api_url="$CURSOR_LINUX_X64_URL"
            ;;
        arm64)
            api_url="$CURSOR_LINUX_ARM64_URL"
            ;;
        *)
            print_error "Unsupported architecture: $arch"
            return 1
            ;;
    esac
    
    local response
    response=$(curl -s "$api_url" 2>/dev/null)
    if [ $? -ne 0 ]; then
        print_error "Failed to fetch version information from Cursor API"
        return 1
    fi
    
    local version
    version=$(echo "$response" | jq -r '.version' 2>/dev/null)
    if [ "$version" = "null" ] || [ -z "$version" ]; then
        print_error "Failed to parse version from API response"
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
// This runs the Cursor updater after every apt upgrade
DPkg::Post-Invoke {"/usr/local/bin/update-cursor || true";};
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

# Main installation function
main() {
    print_status "Starting Cursor IDE installation with auto-updater..."
    
    print_status "Step 1/8: Checking root privileges..."
    check_root
    print_success "Root check passed"
    
    print_status "Step 2/8: Installing dependencies..."
    install_dependencies
    print_success "Dependencies check completed"
    
    print_status "Step 3/8: Testing network connectivity..."
    test_connectivity
    print_success "Network test completed"
    
    print_status "Step 4/8: Fetching latest version information..."
    local version
    version=$(get_latest_version)
    print_success "Latest version: $version"
    
    print_status "Step 5/8: Getting download URL..."
    local download_url
    download_url=$(get_download_url)
    print_success "Download URL obtained"
    
    print_status "Step 6/8: Setting up directory structure..."
    create_cursor_directory
    download_cursor "$version" "$download_url"
    print_success "Cursor installation completed"
    
    print_status "Step 7/8: Creating desktop integration..."
    create_desktop_entry
    print_success "Desktop entry created"
    
    print_status "Step 8/8: Setting up auto-updater..."
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
    print_success "  • Updates will happen automatically when you run 'sudo apt upgrade'"
    print_success "  • Current version: $version"
    print_success ""
    print_status "You can manually check for updates anytime by running: sudo update-cursor"
}

# Run main function
main "$@"
