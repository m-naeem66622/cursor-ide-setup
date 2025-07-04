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

| Component      | Location                                 | Purpose                                |
| -------------- | ---------------------------------------- | -------------------------------------- |
| Cursor IDE     | `/opt/cursor-ai/cursor`                  | The main application binary            |
| Updater Script | `/usr/local/bin/update-cursor`           | Downloads and installs updates         |
| Check Script   | `/usr/local/bin/check-cursor-update`     | Checks for updates without downloading |
| Desktop Entry  | `/usr/share/applications/cursor.desktop` | Makes Cursor appear in your app menu   |
| APT Hook       | `/etc/apt/apt.conf.d/99-cursor-update`   | Triggers check after apt update        |
| Version File   | `/opt/cursor-ai/version.txt`             | Tracks the installed version           |

## 🔧 Features

-   **One-time setup**: Install once, then check for updates and upgrade as needed
-   **Native feel**: Updates integrate with your system's package manager
-   **Safe updates**: Backup previous version during update
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
-   **Check for updates**: `sudo apt update`
-   **Upgrade Cursor**: `sudo update-cursor`

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

1. **Trigger**: Runs automatically after every `sudo cursor-update`
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
├── update-cursor           # Update script
└── check-cursor-update     # Check for updates script

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

# Check for updates (without downloading)
sudo check-cursor-update

# Check latest available version from API
curl -s "https://cursor.com/api/download?platform=linux-x64&releaseTrack=stable" | jq -r '.version'
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
