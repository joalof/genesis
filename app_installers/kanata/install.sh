#!/usr/bin/env bash
set -euo pipefail

# bump this to upgrade: https://github.com/jtroo/kanata/releases
PINNED_VERSION="1.12.0"

INSTALL_DIR="$HOME/apps/kanata"
ARCHIVE="linux-binaries-x64.zip"
# the cmd_allowed variant is the prebuilt equivalent of --features cmd
BINARY="kanata_linux_cmd_allowed_x64"

url="https://github.com/jtroo/kanata/releases/download/v${PINNED_VERSION}/${ARCHIVE}"
echo "Downloading kanata ${PINNED_VERSION}: $url"
curl -fsSL "$url" -o "$ARCHIVE"

STAGING_DIR="${INSTALL_DIR}.new"
rm -rf "$STAGING_DIR"
mkdir -p "${STAGING_DIR}/bin"

# the archive is flat and the binaries carry platform suffixes, so extract just the
# one we want straight to bin/kanata where symfarm expects it
unzip -p "$ARCHIVE" "$BINARY" > "${STAGING_DIR}/bin/kanata"
chmod +x "${STAGING_DIR}/bin/kanata"
rm "$ARCHIVE"

# swap in only on success — preserves the old install if extraction fails
rm -rf "$INSTALL_DIR"
mv "$STAGING_DIR" "$INSTALL_DIR"
symfarm "$INSTALL_DIR"

# Post install setup (idempotent, effectively only does work once per machine)
# https://github.com/jtroo/kanata/blob/main/docs/setup-linux.md

user=$(id -un)
needs_relog=0

# Create the uinput group (if it doesn't exist)
if ! getent group uinput > /dev/null; then
    sudo groupadd --system uinput
fi

# Add the user to the input and uinput groups
for group in input uinput; do
    if ! id -nG "$user" | tr ' ' '\n' | grep -qx "$group"; then
        sudo usermod -aG "$group" "$user"
    fi
    # the *current* session keeps its old credentials until re-login
    if ! id -nG | tr ' ' '\n' | grep -qx "$group"; then
        needs_relog=1
    fi
done

# Load the uinput kernel module (no-op if already loaded or built in)
sudo modprobe uinput

# Make sure the uinput device file has the right permissions by creating udev rule
udev_rule='KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"'
udev_rule_file=/etc/udev/rules.d/99-input.rules
if [[ "$(cat "$udev_rule_file" 2>/dev/null)" != "$udev_rule" ]]; then
    echo "$udev_rule" | sudo tee "$udev_rule_file" > /dev/null
    # reload the udev rule
    sudo udevadm control --reload-rules
    sudo udevadm trigger
fi

# Verify the device file ended up as: crw-rw---- root uinput
if [[ -e /dev/uinput ]]; then
    read -r dev_mode dev_group < <(stat -c '%a %G' /dev/uinput)
    if [[ "$dev_mode" != 660 || "$dev_group" != uinput ]]; then
        echo "kanata: WARNING /dev/uinput is mode $dev_mode group $dev_group, expected 660 uinput" >&2
    fi
else
    echo "kanata: WARNING /dev/uinput does not exist" >&2
fi

if (( needs_relog )); then
    echo "kanata: new group membership does not apply to this session, log out and back in"
fi
