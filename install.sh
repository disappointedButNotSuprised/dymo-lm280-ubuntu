#!/usr/bin/env bash
# Set up the DYMO LabelManager 280 on Ubuntu:
#   1. apt: pipx + libusb
#   2. pipx: labelle (CLI + GUI)
#   3. ~/.local/bin/print-label helper
#   4. udev rule so the printer works without sudo
# Safe to run again - every step is idempotent.
set -euo pipefail

LABELLE_VERSION="${LABELLE_VERSION:-1.4.4}"
RULE_NAME="91-labelle-dymo-lm280.rules"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$HOME/.local/bin"

step() { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }

if [ "$(id -u)" -eq 0 ]; then
    echo "Run as your normal user, not root (sudo is used only where needed)." >&2
    exit 1
fi
if ! command -v apt-get >/dev/null 2>&1; then
    echo "This script expects Ubuntu/Debian (apt-get not found)." >&2
    exit 1
fi

step "Installing system packages (pipx, libusb) - sudo password may be requested"
sudo apt-get update -qq
sudo apt-get install -y pipx libusb-1.0-0

step "Installing labelle $LABELLE_VERSION with pipx"
pipx install --force "labelle==$LABELLE_VERSION"
pipx ensurepath >/dev/null

step "Installing print-label into $BIN_DIR"
install -D -m 755 "$HERE/bin/print-label" "$BIN_DIR/print-label"

step "Installing udev rule /etc/udev/rules.d/$RULE_NAME"
sudo install -m 644 "$HERE/udev/$RULE_NAME" "/etc/udev/rules.d/$RULE_NAME"
sudo udevadm control --reload-rules
sudo udevadm trigger

step "Done"
cat <<EOF
Next:
  1. Open a new terminal (so ~/.local/bin is on PATH).
  2. Unplug and re-plug the printer's USB cable, switch it on.
  3. Try a dry run (no tape used):  labelle --output console "Hello"
  4. Print for real:                print-label "Hello"
     GUI editor:                    labelle-gui
EOF
