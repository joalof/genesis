#!/usr/bin/env bash
# Install Docker Engine from Docker's apt repository and let the current user use it.
# Runs as a mise bootstrap hook on every bootstrap, so every step must be safe to repeat.
set -euo pipefail

keyring=/etc/apt/keyrings/docker.asc

# skip if the repo is configured in any form: a second entry with a different
# signing key makes apt refuse to read its sources at all
if ! grep -rqs download.docker.com /etc/apt/sources.list /etc/apt/sources.list.d/; then
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o "$keyring"
    sudo chmod a+r "$keyring"
    # derivatives (mint, pop) report their own codename, docker only knows ubuntu's
    . /etc/os-release
    sudo tee /etc/apt/sources.list.d/docker.sources > /dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: ${UBUNTU_CODENAME:-$VERSION_CODENAME}
Components: stable
Signed-By: $keyring
EOF
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
