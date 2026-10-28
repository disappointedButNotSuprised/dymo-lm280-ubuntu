# DYMO LabelManager 280 on Ubuntu

DYMO doesn't ship Linux software for the LabelManager 280. This repo sets it up
with [labelle](https://github.com/labelle-org/labelle), an open-source Python
driver that talks to the printer directly over USB, so CUPS and drivers aren't
needed.

Tested on Ubuntu 24.04 with labelle 1.4.4.

## What gets installed

| Piece | Where | Purpose |
|---|---|---|
| `pipx`, `libusb-1.0-0` | apt | Python app installer + USB library |
| `labelle` 1.4.4 (`labelle`, `labelle-gui`) | `~/.local/share/pipx/venvs/labelle`, commands in `~/.local/bin` | The actual printer driver: CLI and GUI editor |
| `print-label` | `~/.local/bin/print-label` | Small shortcut around `labelle` (see below) |
| udev rule | `/etc/udev/rules.d/91-labelle-dymo-lm280.rules` | Lets your normal user access the printer without `sudo` |

## Install

```bash
git clone git@github.com:disappointedButNotSuprised/dymo-lm280-ubuntu.git
cd dymo-lm280-ubuntu
./install.sh
```

The repo is private, so cloning needs a GitHub account with access to it and
an SSH key added to that account. Without a key, use the "Download ZIP" button
on GitHub instead and run `./install.sh` from the unpacked folder (if the
scripts lost their executable bit, run `bash install.sh`).

The script asks for your sudo password (for apt and the udev rule). After it
finishes:

1. Open a new terminal so `~/.local/bin` is on your `PATH`.
2. Unplug the printer's USB cable, plug it back in and switch the printer on.
3. Check that it's visible: `lsusb | grep -i dymo` should show `0922:1005` (or `0922:1006`).

To use a different labelle version: `LABELLE_VERSION=1.5.0 ./install.sh`.

## Use

```bash
print-label "Kitchen"              # one label
print-label                        # asks "Label: " and prints what you type
print-label "Line one" "Line two"  # two-line label, one argument per line
```

`print-label` passes all arguments straight to `labelle`, so every labelle
option works:

```bash
print-label --style bold "BOLD"
print-label --frame-width-px 3 "Framed"
print-label --qr "https://example.com" "Scan me"
print-label --barcode-with-text 123456789012 --barcode-type ean13
print-label --fixed-length 50 --justify center "50 mm wide"
print-label --tape-size-mm 9 "On 9 mm tape"   # match the cassette: 6, 9 or 12 mm
```

**Preview without wasting tape:** add `--output console` (draws the label in
the terminal) or `--output browser` (opens a PNG):

```bash
labelle --output console "Hello"
```

**Many labels in a row** (for example a list of IDs, one per line in `ids.txt`):

```bash
while read -r id; do print-label "$id"; done < ids.txt
```

**GUI editor:** run `labelle-gui`, which has a live preview and lets you mix
text, QR codes, barcodes and images.

`labelle --help` lists all options.

## Troubleshooting

| Symptom | Fix |
|---|---|
| `labelle: command not found` | Open a new terminal, or run `pipx ensurepath` and log out/in. |
| "No supported devices found" | Printer is off or the cable is unplugged. Check `lsusb \| grep -i dymo`. |
| Permission / access denied | The udev rule wasn't applied yet: unplug and re-plug the printer. If `lsusb` shows a product ID other than `1005`/`1006`, add it to `udev/91-labelle-dymo-lm280.rules` and run `./install.sh` again. |
| Text is cut off or too small | Use `--tape-size-mm` to match the tape cassette, `--font-scale` for size. |

You don't need a CUPS printer queue for this. If Ubuntu added a
"LabelManager-280" printer automatically, you can ignore it.

## Uninstall

```bash
./uninstall.sh
```

This removes labelle, `print-label` and the udev rule. The apt packages stay
installed.
