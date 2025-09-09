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

### Check for Updates & Upgrade

To check for Cursor updates:

```bash
sudo apt update
```

To upgrade Cursor (if an update is available):

```bash
sudo update-cursor
```

> **Note:** `sudo apt upgrade` does NOT upgrade Cursor automatically. You must run `sudo update-cursor` to perform the upgrade.

### Testing Installation

Verify everything works:

```bash
./test-installation.sh
```

## 📋 What Gets Installed

| Component      | Location                                           | Purpose                                |
| -------------- | -------------------------------------------------- | -------------------------------------- |
| Cursor IDE     | `/usr/local/bin/cursor`                            | The main application binary (AppImage) |
| Updater Script | `/usr/local/bin/update-cursor`                     | Downloads and installs updates         |
| Check Script   | `/usr/local/bin/check-cursor-update`               | Checks for updates without downloading |
| Desktop Entry  | `/usr/share/applications/cursor.desktop`           | Makes Cursor appear in your app menu   |
| APT Hook       | `/etc/apt/apt.conf.d/99-cursor-update`             | Triggers check after apt update        |
| Version File   | `/usr/local/share/cursor-ai/version.txt`           | Tracks the installed version           |
| Icon File      | `/usr/local/share/cursor-ai/cursor.png`            | Application icon for desktop entry     |
| System Config  | `/etc/sysctl.d/60-cursor-unprivileged-userns.conf` | Kernel config (created only if needed) |

## 🔧 Features

- **One-time setup**: Install once, then check for updates and upgrade as needed
- **Native feel**: Updates integrate with your system's package manager
- **Safe updates**: Backup previous version during update
- **Launch issue detection**: Automatically fixes common AppImage startup problems
- **Clean installation**: Follows Linux filesystem standards
- **Easy removal**: Complete uninstall script provided
- **Debug support**: Comprehensive debugging tools included

## 📖 Usage

### Installation

```bash
sudo ./install-cursor.sh
```

The installer will:

1. Check and install dependencies (`wget`, `curl`, `jq`)
2. Download the latest Cursor IDE from Cursor's official API
3. Set up the application in `/usr/local/share/cursor-ai/` and `/usr/local/bin/`
4. Create a desktop entry for your app menu
5. Detect and fix common launch issues (FUSE library, sandbox errors)
6. Install the auto-updater system

### Daily Usage

- **Launch Cursor**: Open your application menu and search for "Cursor"
- **Check for updates**: `sudo apt update`
- **Upgrade Cursor**: `sudo update-cursor`

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
2. **Download**: Fetches the latest Cursor AppImage from Cursor's official API
3. **Setup**: Places files in standard Linux locations
4. **Launch Issues**: Detects and fixes common AppImage startup problems (FUSE, sandbox)
5. **Integration**: Creates desktop entry and APT hook

### Auto-Update Process

1. **Check**: `sudo apt update` queries Cursor's API for the latest version
2. **Compare**: Compares with locally installed version
3. **Notify**: Displays update availability message
4. **Update**: `sudo update-cursor` downloads and installs new version if available
5. **Backup**: Keeps backup of previous version during update

### File Structure

```
/usr/local/share/cursor-ai/
├── cursor.png          # Application icon
└── version.txt         # Version tracking file

/usr/local/bin/
└── cursor              # Main application binary (AppImage)
└── version.txt         # Current version info

/usr/local/bin/
├── update-cursor           # Update script
└── check-cursor-update     # Check for updates script

/usr/share/applications/
└── cursor.desktop      # Desktop entry

/etc/apt/apt.conf.d/
└── 99-cursor-update    # APT hook configuration

/etc/sysctl.d/
└── 60-cursor-unprivileged-userns.conf  # Kernel config (created only if needed)
```

## 🔍 Troubleshooting

### Debug Installation Issues

If you encounter problems during installation, use the debug script:

```bash
sudo ./debug-install.sh
```

This will test:

- Network connectivity to Cursor's servers
- API endpoint accessibility
- Download URL validation
- Architecture detection
- Dependencies availability

### Common Issues

**"Command not found: jq"**

```bash
sudo apt update && sudo apt install jq
```

**Cursor won't start (FUSE error)**

```bash
# Install FUSE library
sudo apt update && sudo apt install libfuse2
```

**Cursor won't start (sandbox error)**

```bash
# Check if --no-sandbox flag was added to desktop entry
grep "no-sandbox" /usr/share/applications/cursor.desktop

# If not present, the installer should have detected this automatically
# Try reinstalling: sudo ./install-cursor.sh
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
cat /usr/local/share/cursor-ai/version.txt

# Check for updates (without downloading)
sudo check-cursor-update

# Check latest available version from API
curl -s "https://cursor.com/api/download?platform=linux-x64&releaseTrack=stable" | jq -r '.version'
```

### Logs

The updater provides colored output during system updates:

- 🔵 Blue: Status messages
- 🟢 Green: Success messages
- 🟡 Yellow: Warnings
- 🔴 Red: Errors

## ⚡ Advanced Usage

### Configuration File

The project includes a `config.conf` file with default settings that can be customized:

```bash
# View current configuration
cat config.conf

# Key settings you can modify:
# - CURSOR_INSTALL_DIR: Installation directory
# - DOWNLOAD_TIMEOUT: Download timeout in seconds
# - AUTO_UPDATE_ENABLED: Enable/disable auto-updates
# - USE_COLORS: Enable/disable colored output
```

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
# Change these lines in install-cursor.sh
CURSOR_DIR="/your/custom/data/path"
CURSOR_BINARY="/your/custom/bin/path/cursor"
```

Or modify the `config.conf` file:

```bash
CURSOR_INSTALL_DIR="/your/custom/data/path"
```

### Project Structure

```
cursor-ide-setup/
├── install-cursor.sh       # Main installer script
├── uninstall-cursor.sh     # Complete removal script
├── test-installation.sh    # Installation validation
├── debug-install.sh        # Debug and troubleshooting
├── config.conf            # Configuration settings
├── Makefile              # Build automation
├── README.md             # This documentation
├── CHANGELOG.md          # Version history
└── ISSUES.md             # Known issues and solutions
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

- Cursor team for creating an amazing AI-powered code editor
- Linux community for filesystem standards and best practices
