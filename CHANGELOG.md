# Changelog

All notable changes to the Cursor IDE Auto-Updater project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.5] - Cursor API Migration & Compatibility Update

### Changed

- **BREAKING CHANGE**: Migrated from deprecated Cursor JSON API endpoints to HTML parsing method
- Updated download URL extraction to parse AppImage URLs directly from `https://cursor.com/download` page
- Replaced JSON API calls (`cursor.com/api/download`) with HTML content parsing using `grep` and `sed`
- Updated version detection to extract version numbers from AppImage filename patterns
- Modified all API-dependent functions in installation, update, and check scripts

### Fixed

- **Critical API compatibility issue**: Resolved "Failed to parse version/download URL from API response" errors
- Fixed installation script failures due to Cursor's API endpoint changes
- Restored functionality for both x64 and arm64 architecture support
- Fixed debug script to properly validate download URLs and version extraction
- Resolved update checker and auto-updater scripts that were broken by API changes

### Technical Details

- **API Migration**: Replaced `jq` JSON parsing with `grep -o` HTML pattern matching
- **URL Pattern**: Updated to extract URLs matching `https://downloads.cursor.com[^"]*{x86_64|aarch64}\.AppImage`
- **Version Extraction**: Now parses version from AppImage filename pattern `Cursor-[version]-`
- **Architecture Detection**: Enhanced support for both `x86_64` and `aarch64` AppImage variants
- **Error Handling**: Improved error messages to reflect new parsing method

### Script Updates

#### Main Installation Script (`install-cursor.sh`)

- Updated `get_latest_version()` function to parse HTML instead of JSON
- Modified `get_download_url()` function with HTML pattern matching
- Removed dependency on JSON API endpoints
- Enhanced architecture-specific URL extraction

#### Debug Script (`debug-install.sh`)

- Migrated from JSON API testing to HTML parsing validation
- Updated URL accessibility tests for both architectures
- Enhanced diagnostic output with truncated URLs for better readability
- Fixed version and download URL parsing validation

#### Auto-Update Components

- **Check Script**: Updated `get_latest_cursor_version()` in generated check script
- **Updater Script**: Modified `get_download_url()` and `get_latest_cursor_version()` functions
- **APT Integration**: Maintained compatibility with APT hooks and update mechanisms

### Compatibility

- **Backward Compatible**: No changes to installation directory structure or user-facing commands
- **Forward Compatible**: New parsing method is more resilient to future website changes
- **Multi-Architecture**: Continued support for x64 and arm64 systems
- **Dependency Management**: Maintains existing dependency requirements (wget, curl, jq)

### Validation

- Successfully tested with Cursor version 1.6.35
- Verified AppImage download accessibility for both architectures
- Confirmed proper version extraction and URL parsing
- Validated complete installation and update workflow

### Migration Notes

- **No User Action Required**: Existing installations will automatically use new API method on next update check
- **Immediate Fix**: Resolves current installation failures without reinstallation
- **API Resilience**: Less dependent on specific API endpoint availability

## [1.0.4] - Directory Structure Reorganization

### Changed

- **BREAKING CHANGE**: Moved installation directory from `/opt/cursor-ai/` to `/usr/local/share/cursor-ai/`
- **BREAKING CHANGE**: Moved binary from `/opt/cursor-ai/cursor` to `/usr/local/bin/cursor`
- Updated all scripts to use the new directory structure
- Updated configuration files and documentation

### Benefits

- Follows Linux Filesystem Hierarchy Standard (FHS) more closely
- Reduces permission issues that occurred with `/opt/cursor` directory usage
- Separates binary files from data files appropriately
- Safer installation location that doesn't require special root directory handling

### Technical Details

- Installs to `/usr/local/share/cursor-ai/` and `/usr/local/bin/` following Linux standards

### File Structure

```
/usr/local/share/cursor-ai/
├── cursor.png          # Application icon
└── version.txt         # Version tracking file

/usr/local/bin/
└── cursor              # Main application binary (AppImage)
```

## [1.0.3] - 2025-01-27

### Fixed

- **Critical synchronization issue**: Added missing cleanup for system configuration file (`/etc/sysctl.d/60-cursor-unprivileged-userns.conf`) in uninstall script
- Uninstall script now properly removes all files created during installation, ensuring complete cleanup
- Added automatic sysctl configuration reload during uninstallation to apply kernel parameter changes

### Improved

- Enhanced uninstall script with comprehensive file removal tracking and status reporting
- Updated documentation to reflect all installed components including conditional system configuration files
- Improved project structure documentation with complete file listings and purposes

### Documentation

- Updated README.md with latest features, file structure, and troubleshooting information
- Added debug script documentation and usage instructions
- Enhanced troubleshooting section with specific solutions for FUSE and sandbox errors
- Added configuration file documentation and advanced usage examples
- Updated installation process documentation to include launch issue detection

### Technical Details

- The uninstall script now includes cleanup for the sysctl configuration file that is conditionally created during installation
- Added proper error handling and system configuration reload to ensure clean removal
- Improved synchronization between installation and uninstallation processes

## [1.0.2] - 2025-07-23

### Added

- Comprehensive launch issue detection and resolution system during installation to prevent common AppImage startup failures
- Helper function `update_desktop_entry_no_sandbox()` to automatically add `--no-sandbox` flag to desktop entries when needed
- Enhanced sandbox error detection with expanded keyword matching for better troubleshooting
- Automatic FUSE library installation (`libfuse2`) when missing to support AppImage execution
- Kernel parameter adjustment for unprivileged user namespace cloning to resolve Electron sandbox errors

### Changed

- Improved installation workflow with reordered steps: desktop entry creation now occurs before launch issue detection to enable proper `--no-sandbox` flag application
- Enhanced sandbox detection logic to run version checks as the original user when using sudo, preventing "Running as root without --no-sandbox" errors
- Streamlined version check logic by removing conditional execution complexity while maintaining headless verification functionality
- Updated warning messages to include exit codes for better diagnostic information
- Expanded list of known sandbox error keywords including "Running as root without --no-sandbox" for more comprehensive error handling

### Fixed

- Resolved AppImage launch failures on systems missing FUSE library support
- Fixed sandbox namespace errors that prevented Cursor from starting on certain Linux configurations
- Corrected root execution issues during version checks by implementing proper user context switching
- Improved error handling for launch issues while preserving existing diagnostic capabilities

### Technical Details

- The installation script now performs a one-time comprehensive check for common launch issues, eliminating runtime costs on subsequent launches
- Added automatic detection and installation of `libfuse2` when not present in the system
- Implemented kernel parameter modification (`kernel.unprivileged_userns_clone=1`) with persistent configuration via `/etc/sysctl.d/60-cursor-unprivileged-userns.conf`
- Enhanced sandbox detection uses `runuser` to execute version checks as the original user when running under sudo
- Desktop entry modification logic ensures `--no-sandbox` flag is only added when necessary and not duplicated
- Improved error pattern matching covers a broader range of Electron/Chromium sandbox-related failures

### Security

- Maintained secure installation practices while adding necessary workarounds for sandbox restrictions
- Proper privilege handling during user context switching for version checks
- Safe kernel parameter modification with system-wide persistence

### File Structure

/etc/sysctl.d/
└── 60-cursor-unprivileged-userns.conf # Kernel config (created only if needed)

## [1.0.1] - 2025-07-04

### Added

- New check-only script (`/usr/local/bin/check-cursor-update`) that checks for Cursor IDE updates without downloading or installing. This script is now run after every `apt update` (not `apt upgrade`), improving integration with standard Linux update workflows.
- Test coverage for the new check script in `test-installation.sh`.
- Uninstallation logic for the check script in `uninstall-cursor.sh`.

### Changed

- The APT hook now runs the check-only script after `apt update` instead of running the updater after `apt upgrade`.
- The update process is now split: `sudo apt update` checks for updates, and `sudo update-cursor` performs the upgrade if a new version is available.
- Updated README.md to reflect the new update workflow, clarify the difference between checking for updates and upgrading, and document the new check script. Improved documentation for update and upgrade commands, and updated the list of installed components and features.
- The test script now checks for the presence and executability of the check script, and verifies that the APT hook references the correct script.
- Network connectivity tests in the test script now use the official Cursor API endpoint instead of GitHub.

### Technical Details

- The core reason for this change: the previous approach using an APT hook after `apt upgrade` only triggered the Cursor update if there were other real APT package upgrades available. If there were no other packages to upgrade, the Cursor update would not occur, even if a new Cursor version was available. By switching to a hook after `apt update`, the check for Cursor updates always runs, ensuring users are notified of new versions regardless of other system package upgrades.
- The installer now creates the check-only script and ensures it is executable.
- The uninstaller removes the check-only script if present.
- The APT hook is updated to reference the check script and only runs after `apt update`.
- All scripts and documentation updated to reflect the new workflow and file locations.

### File Structure

```
/opt/cursor-ai/
├── cursor              # Main application binary (AppImage)
├── cursor.png          # Application icon
└── version.txt         # Version tracking

/usr/local/bin/
├── update-cursor           # Update script
└── check-cursor-update     # Check for updates script

/usr/share/applications/
└── cursor.desktop      # Desktop entry

/etc/apt/apt.conf.d/
└── 99-cursor-update    # APT integration hook (runs check script after apt update)
```

### Migration Notes

- Users should now run `sudo apt update` to check for updates and `sudo update-cursor` to upgrade Cursor IDE. The update will no longer happen automatically after `apt upgrade`.
- The new check script improves compatibility with standard Linux update practices and provides a safer, more predictable update experience.

## [1.0.0] - 2025-07-03

### Added

- Initial release of Cursor IDE Auto-Updater
- Main installer script (`install-cursor.sh`) with official Cursor API integration
- Auto-updater script that integrates with APT using `https://cursor.com/api/download?platform=linux-x64&releaseTrack=stable`
- Desktop entry creation for application menu integration
- Uninstaller script for clean removal
- Test script to validate installation
- Comprehensive README with usage instructions
- Makefile for easy project management
- Automatic backup and rollback functionality
- Colored terminal output for better user experience
- Network error handling and graceful fallbacks
- Official Cursor API integration for version checking and downloads
- Linux filesystem standard compliance

### Features

- One-time installation with automatic updates
- Updates triggered by `sudo apt upgrade`
- Safe update process with backup/rollback
- Desktop integration (app menu entry)
- Version tracking and comparison using Cursor's official API
- Network connectivity checks for Cursor services
- Dependency management (wget, curl, jq)
- Clean uninstallation option
- Installation validation testing

### Technical Details

- Installs to `/opt/cursor-ai/` following Linux standards
- Creates APT hook in `/etc/apt/apt.conf.d/`
- Updater script in `/usr/local/bin/`
- Desktop entry in `/usr/share/applications/`
- Official Cursor API integration for releases
- AppImage format support
- Root privilege validation
- Error handling and user feedback

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

- All operations require root privileges
- Safe file handling with backup creation
- Network request validation
- Input sanitization for version strings
- Graceful error handling without system damage

### Compatibility

- Tested on Ubuntu/Debian-based systems
- Requires APT package manager
- Works with systemd and traditional init systems
- Compatible with GNOME, KDE, and other desktop environments

---

## Future Improvements (Planned)

### [1.1.0] - Future

- Support for other Linux distributions (Fedora, Arch, etc.)
- Configuration file for custom settings
- Logging system for update history
- Update notifications for desktop environments
- Scheduled update checks (independent of APT)
- Multiple installation locations support

### [1.2.0] - Future

- GUI installer option
- Update rollback functionality
- Differential updates for faster downloads
- Proxy support for corporate environments
- Custom GitHub repository support
- Beta/stable channel selection

---

## Contributing

To contribute to this project:

1. Fork the repository
2. Create a feature branch
3. Test your changes thoroughly
4. Update this changelog
5. Submit a pull request

### Development Guidelines

- Follow bash best practices
- Add error handling for all operations
- Test on multiple Linux distributions
- Document all user-facing changes
- Maintain backward compatibility when possible
