# Cursor IDE Auto-Updater Makefile

.PHONY: install uninstall test clean help

# Default target
help:
	@echo "Cursor IDE Auto-Updater Setup"
	@echo ""
	@echo "Available targets:"
	@echo "  install    - Install Cursor IDE with auto-updater (requires sudo)"
	@echo "  uninstall  - Remove Cursor IDE and all components (requires sudo)"
	@echo "  test       - Test the installation"
	@echo "  debug      - Run debug installation check (requires sudo)"
	@echo "  clean      - Clean up any temporary files"
	@echo "  help       - Show this help message"
	@echo ""
	@echo "Usage examples:"
	@echo "  sudo make install    # Install Cursor IDE"
	@echo "  make test           # Test installation (no sudo needed)"
	@echo "  sudo make debug     # Debug installation issues"
	@echo "  sudo make uninstall # Remove Cursor IDE"

install:
	@echo "Installing Cursor IDE with auto-updater..."
	@if [ "$$(id -u)" != "0" ]; then \
		echo "Error: This target requires sudo privileges"; \
		echo "Run: sudo make install"; \
		exit 1; \
	fi
	./install-cursor.sh

uninstall:
	@echo "Uninstalling Cursor IDE..."
	@if [ "$$(id -u)" != "0" ]; then \
		echo "Error: This target requires sudo privileges"; \
		echo "Run: sudo make uninstall"; \
		exit 1; \
	fi
	./uninstall-cursor.sh

test:
	@echo "Testing Cursor IDE installation..."
	./test-installation.sh

clean:
	@echo "Cleaning up temporary files..."
	@find . -name "*.backup" -delete 2>/dev/null || true
	@find . -name "*.tmp" -delete 2>/dev/null || true
	@echo "Clean complete"

# Development targets
check-scripts:
	@echo "Checking script syntax..."
	@for script in *.sh; do \
		echo "Checking $$script..."; \
		bash -n "$$script" && echo "  ✓ Syntax OK" || echo "  ✗ Syntax Error"; \
	done

permissions:
	@echo "Setting correct permissions..."
	chmod +x *.sh
	@echo "Permissions set"

debug:
	@echo "Running debug installation check..."
	@if [ "$$(id -u)" != "0" ]; then \
		echo "Error: Debug target requires sudo privileges"; \
		echo "Run: sudo make debug"; \
		exit 1; \
	fi
	./debug-install.sh
