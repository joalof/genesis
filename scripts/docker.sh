#!/usr/bin/env bash
# Install Docker Engine from Docker's apt repository and let the current user use it.
# Runs as a mise bootstrap hook on every bootstrap, so every step must be safe to repeat.
set -euo pipefail

keyring=/usr/share/keyrings/docker-archive-keyring.gpg
sources=/etc/apt/sources.list.d/docker.list

if [[ ! -f $keyring ]]; then
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o "$keyring"
fi

if [[ ! -f $sources ]]; then
    # derivatives (mint, pop) report their own codename, docker only knows ubuntu's
    . /etc/os-release
    echo "deb [arch=$(dpkg --print-architecture) signed-by=$keyring] https://download.docker.com/linux/ubuntu ${UBUNTU_CODENAME:-$VERSION_CODENAME} stable" \
        | sudo tee "$sources" > /dev/null
    sudo apt-get update
fi

if ! dpkg -s docker-ce > /dev/null 2>&1; then
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io
fi

sudo groupadd -f docker
user=$(id -un)
if ! id -nG "$user" | tr ' ' '\n' | grep -qx docker; then
    sudo usermod -aG docker "$user"
    echo "docker: new group membership does not apply to this session, log out and back in"
fi
