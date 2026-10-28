#!/usr/bin/env bash
# Remove everything install.sh added. System packages (pipx, libusb) are left in place.
set -euo pipefail

RULE="/etc/udev/rules.d/91-labelle-dymo-lm280.rules"

pipx uninstall labelle 2>/dev/null || echo "labelle was not installed via pipx"
rm -f "$HOME/.local/bin/print-label"

if [ -e "$RULE" ]; then
    sudo rm -f "$RULE"
    sudo udevadm control --reload-rules
fi

echo "Uninstalled."
