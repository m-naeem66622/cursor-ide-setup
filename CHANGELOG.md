# Changelog

All notable changes to the Cursor IDE Auto-Updater project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.1] - 2025-07-04

### Added

-   New check-only script (`/usr/local/bin/check-cursor-update`) that checks for Cursor IDE updates without downloading or installing. This script is now run after every `apt update` (not `apt upgrade`), improving integration with standard Linux update workflows.
-   Test coverage for the new check script in `test-installation.sh`.
-   Uninstallation logic for the check script in `uninstall-cursor.sh`.

### Changed

-   The APT hook now runs the check-only script after `apt update` instead of running the updater after `apt upgrade`.
-   The update process is now split: `sudo apt update` checks for updates, and `sudo update-cursor` performs the upgrade if a new version is available.
-   Updated README.md to reflect the new update workflow, clarify the difference between checking for updates and upgrading, and document the new check script. Improved documentation for update and upgrade commands, and updated the list of installed components and features.
-   The test script now checks for the presence and executability of the check script, and verifies that the APT hook references the correct script.
-   Network connectivity tests in the test script now use the official Cursor API endpoint instead of GitHub.

### Technical Details

-   The core reason for this change: the previous approach using an APT hook after `apt upgrade` only triggered the Cursor update if there were other real APT package upgrades available. If there were no other packages to upgrade, the Cursor update would not occur, even if a new Cursor version was available. By switching to a hook after `apt update`, the check for Cursor updates always runs, ensuring users are notified of new versions regardless of other system package upgrades.
-   The installer now creates the check-only script and ensures it is executable.
-   The uninstaller removes the check-only script if present.
-   The APT hook is updated to reference the check script and only runs after `apt update`.
-   All scripts and documentation updated to reflect the new workflow and file locations.

### File Structure

```
/opt/cursor-ai/
├── cursor              # Main application binary
├── cursor.png          # Application icon
└── version.txt         # Version tracking

/usr/local/bin/
├── update-cursor           # Update script
└── check-cursor-update     # Check for updates script

/usr/share/applications/
└── cursor.desktop      # Desktop entry

/etc/apt/apt.conf.d/
└── 99-cursor-update    # APT integration hook (now runs check script after apt update)
```

### Migration Notes

-   Users should now run `sudo apt update` to check for updates and `sudo update-cursor` to upgrade Cursor IDE. The update will no longer happen automatically after `apt upgrade`.
-   The new check script improves compatibility with standard Linux update practices and provides a safer, more predictable update experience.

## [1.0.0] - 2025-07-03

### Added

-   Initial release of Cursor IDE Auto-Updater
-   Main installer script (`install-cursor.sh`) with official Cursor API integration
-   Auto-updater script that integrates with APT using `https://cursor.com/api/download?platform=linux-x64&releaseTrack=stable`
-   Desktop entry creation for application menu integration
-   Uninstaller script for clean removal
-   Test script to validate installation
-   Comprehensive README with usage instructions
-   Makefile for easy project management
-   Automatic backup and rollback functionality
-   Colored terminal output for better user experience
-   Network error handling and graceful fallbacks
-   Official Cursor API integration for version checking and downloads
-   Linux filesystem standard compliance

### Features

-   One-time installation with automatic updates
-   Updates triggered by `sudo apt upgrade`
-   Safe update process with backup/rollback
-   Desktop integration (app menu entry)
-   Version tracking and comparison using Cursor's official API
-   Network connectivity checks for Cursor services
-   Dependency management (wget, curl, jq)
-   Clean uninstallation option
-   Installation validation testing

### Technical Details

-   Installs to `/opt/cursor-ai/` following Linux standards
-   Creates APT hook in `/etc/apt/apt.conf.d/`
-   Updater script in `/usr/local/bin/`
-   Desktop entry in `/usr/share/applications/`
-   Official Cursor API integration for releases
-   AppImage format support
-   Root privilege validation
-   Error handling and user feedback

### File Structure

```
/opt/cursor-ai/
├── cursor              # Main application binary
├── cursor.png          # Application icon
└── version.txt         # Version tracking

/usr/local/bin/
└── update-cursor       # Auto-updater script

/usr/share/applications/
└── cursor.desktop      # Desktop entry

/etc/apt/apt.conf.d/
└── 99-cursor-update    # APT integration hook
```

### Security

-   All operations require root privileges
-   Safe file handling with backup creation
-   Network request validation
-   Input sanitization for version strings
-   Graceful error handling without system damage

### Compatibility

-   Tested on Ubuntu/Debian-based systems
-   Requires APT package manager
-   Works with systemd and traditional init systems
-   Compatible with GNOME, KDE, and other desktop environments

---

## Future Improvements (Planned)

### [1.1.0] - Future

-   Support for other Linux distributions (Fedora, Arch, etc.)
-   Configuration file for custom settings
-   Logging system for update history
-   Update notifications for desktop environments
-   Scheduled update checks (independent of APT)
-   Multiple installation locations support

### [1.2.0] - Future

-   GUI installer option
-   Update rollback functionality
-   Differential updates for faster downloads
-   Proxy support for corporate environments
-   Custom GitHub repository support
-   Beta/stable channel selection

---

## Contributing

To contribute to this project:

1. Fork the repository
2. Create a feature branch
3. Test your changes thoroughly
4. Update this changelog
5. Submit a pull request

### Development Guidelines

-   Follow bash best practices
-   Add error handling for all operations
-   Test on multiple Linux distributions
-   Document all user-facing changes
-   Maintain backward compatibility when possible
