#!/usr/bin/env bash
# Give the current user access to /dev/uinput so kanata can run without root.
# Runs as a mise bootstrap hook on every bootstrap, so every step must be safe to repeat.
# https://github.com/jtroo/kanata/blob/main/docs/setup-linux.md
set -euo pipefail

if [[ -n "${WSL_DISTRO_NAME:-}" ]]; then
    echo "kanata: skipping uinput setup on WSL"
    exit 0
fi

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
