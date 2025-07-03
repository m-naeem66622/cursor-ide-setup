# Cursor IDE Auto-Updater Setup

This project provides scripts to install Cursor IDE on Linux with automatic updates that integrate seamlessly with your system's package manager.

## 🚀 Quick Start

### Installation (One-time setup)

```bash
# Clone or download this repository
git clone <repository-url>
cd cursor-ide-setup

# Run the installer (requires sudo)
sudo ./install-cursor.sh
```

**What happens during installation:**

```
[Cursor Installer] Starting Cursor IDE installation with auto-updater...- Safe update process with backup/rollback
[Cursor Installer] Step 1/8: Checking root privileges...
[Cursor Installer] Root check passed
[Cursor Installer] Step 2/8: Installing dependencies...
[Cursor Installer] Checking dependencies...
[Cursor Installer] All dependencies are already installed
[Cursor Installer] Dependencies check completed
[Cursor Installer] Step 3/8: Testing network connectivity...
[Cursor Installer] Testing network connectivity...
[Cursor Installer] Network connectivity test passed
[Cursor Installer] Network test completed
[Cursor Installer] Step 4/8: Fetching latest version information...
[Cursor Installer] Latest version: 1.1.7
[Cursor Installer] Step 5/8: Getting download URL...
[Cursor Installer] Download URL obtained
[Cursor Installer] Step 6/8: Setting up directory structure...
[Cursor Installer] Creating Cursor directory at /opt/cursor-ai...
[Cursor Installer] Created directory /opt/cursor-ai
[Cursor Installer] Downloading Cursor 1.1.7...
--2025-07-03 18:35:56--  https://downloads.cursor.com/production/...
[Cursor Installer] Cursor 1.1.7 installed successfully
[Cursor Installer] Step 7/8: Creating desktop integration...
[Cursor Installer] Desktop entry created at /usr/share/applications/cursor.desktop
[Cursor Installer] Step 8/8: Setting up auto-updater...
[Cursor Installer] Auto-updater configured
[Cursor Installer] Installation complete!
```

### Automatic Updates

From now on, whenever you update your system:

```bash
sudo apt update && sudo apt upgrade
```

You'll see Cursor updates automatically:

```
[Cursor Updater] Checking for Cursor updates...
[Cursor Updater] Current version: v0.42.3
[Cursor Updater] Latest version: v0.42.4
[Cursor Updater] New version available: v0.42.3 → v0.42.4
[Cursor Updater] Update complete! Cursor updated to v0.42.4
```

### Testing Installation

Verify everything works:

```bash
./test-installation.sh
```

Expected output:

```
========================================
  Cursor IDE Installation Test Suite
========================================

[Test] Checking dependencies...
[PASS] All dependencies are installed: wget curl jq

[Test] Checking Cursor binary...
[PASS] Cursor binary exists and is executable

[Test] Checking version file...
[PASS] Version file exists with version: v0.42.3

[Test] Checking updater script...
[PASS] Updater script exists and is executable

[Test] Checking desktop file...
[PASS] Desktop file exists with correct content

[Test] Checking APT hook...
[PASS] APT hook exists and references updater script

[Test] Testing updater functionality (dry run)...
[PASS] Network connectivity to GitHub API is working

========================================
  Test Results
========================================
Total tests: 7
Passed: 7
Failed: 0

[PASS] All tests passed! Cursor IDE is properly installed.
```

## 📋 What Gets Installed

| Component      | Location                                 | Purpose                              |
| -------------- | ---------------------------------------- | ------------------------------------ |
| Cursor IDE     | `/opt/cursor-ai/cursor`                  | The main application binary          |
| Updater Script | `/usr/local/bin/update-cursor`           | Handles automatic updates            |
| Desktop Entry  | `/usr/share/applications/cursor.desktop` | Makes Cursor appear in your app menu |
| APT Hook       | `/etc/apt/apt.conf.d/99-cursor-update`   | Triggers updates after `apt upgrade` |
| Version File   | `/opt/cursor-ai/version.txt`             | Tracks the installed version         |

## 🔧 Features

-   **One-time setup**: Install once, updates happen automatically
-   **Native feel**: Updates integrate with your system's package manager
-   **Safe updates**: Automatic backup and rollback on failure
-   **Clean installation**: Follows Linux filesystem standards
-   **Easy removal**: Complete uninstall script provided

## 📖 Usage

### Installation

```bash
sudo ./install-cursor.sh
```

The installer will:

1. Check and install dependencies (`wget`, `curl`, `jq`)
2. Download the latest Cursor IDE from GitHub
3. Set up the application in `/opt/cursor-ai/`
4. Create a desktop entry for your app menu
5. Install the auto-updater system

### Daily Usage

-   **Launch Cursor**: Open your application menu and search for "Cursor"
-   **Manual Update Check**: `sudo update-cursor`
-   **System Updates** (includes Cursor): `sudo apt update && sudo apt upgrade`

### Uninstallation

```bash
sudo ./uninstall-cursor.sh
```

### Using the Makefile

```bash
# Install
sudo make install

# Test
make test

# Uninstall
sudo make uninstall

# See all options
make help
```

## 🛠 How It Works

### Installation Process

1. **Dependencies**: Ensures `wget`, `curl`, and `jq` are installed
2. **Download**: Fetches the latest Cursor AppImage from GitHub releases
3. **Setup**: Places files in standard Linux locations
4. **Integration**: Creates desktop entry and APT hook

### Auto-Update Process

1. **Trigger**: Runs automatically after every `apt upgrade`
2. **Check**: Queries GitHub API for the latest version
3. **Compare**: Compares with locally installed version
4. **Update**: Downloads and installs new version if available
5. **Backup**: Keeps backup of previous version during update

### File Structure

```
/opt/cursor-ai/
├── cursor              # Main application binary (AppImage)
├── cursor.png          # Application icon
└── version.txt         # Current version info

/usr/local/bin/
└── update-cursor       # Auto-updater script

/usr/share/applications/
└── cursor.desktop      # Desktop entry

/etc/apt/apt.conf.d/
└── 99-cursor-update    # APT hook configuration
```

## 🔍 Troubleshooting

### Common Issues

**"Command not found: jq"**

```bash
sudo apt update && sudo apt install jq
```

**Updates not working**

```bash
# Check if the updater script exists and is executable
ls -la /usr/local/bin/update-cursor

# Test the updater manually
sudo update-cursor
```

**Cursor not appearing in app menu**

```bash
# Refresh the desktop database
sudo update-desktop-database
```

**Permission errors**

```bash
# Ensure scripts are run with sudo
sudo ./install-cursor.sh
```

### Manual Version Check

```bash
# Check installed version
cat /opt/cursor-ai/version.txt

# Check latest available version
curl -s https://api.github.com/repos/getcursor/cursor/releases/latest | jq -r '.tag_name'
```

### Logs

The updater provides colored output during system updates:

-   🔵 Blue: Status messages
-   🟢 Green: Success messages
-   🟡 Yellow: Warnings
-   🔴 Red: Errors

## ⚡ Advanced Usage

### Disable Auto-Updates

```bash
sudo rm /etc/apt/apt.conf.d/99-cursor-update
```

### Re-enable Auto-Updates

```bash
sudo ./install-cursor.sh  # Will recreate the APT hook
```

### Custom Installation Directory

Edit the `CURSOR_DIR` variable in `install-cursor.sh` before running:

```bash
# Change this line in install-cursor.sh
CURSOR_DIR="/your/custom/path"
```

## 🤝 Contributing

Feel free to submit issues and enhancement requests!

### Development

To modify the scripts:

1. Edit the appropriate script file
2. Test in a virtual environment
3. Ensure proper error handling
4. Update this README if needed

## 📄 License

This project is open source. Use at your own risk.

## 🙏 Acknowledgments

-   Cursor team for creating an amazing AI-powered code editor
-   Linux community for filesystem standards and best practices
