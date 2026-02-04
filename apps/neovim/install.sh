#!/usr/bin/env bash
set -euo pipefail
cd ~/.local/src/
git clone https://github.com/neovim/neovim.git
cd neovim/
git checkout nightly
INSTALL_DIR="$HOME/apps/neovim"
STAGING_DIR="${INSTALL_DIR}.new"
rm -rf "$STAGING_DIR"
mkdir -p "$STAGING_DIR"
make CMAKE_BUILD_TYPE=Release CMAKE_INSTALL_PREFIX="${STAGING_DIR}"
make CMAKE_BUILD_TYPE=Release CMAKE_INSTALL_PREFIX="${STAGING_DIR}" install
# swap in only on success — preserves the old install if the build fails
rm -rf "$INSTALL_DIR"
mv "$STAGING_DIR" "$INSTALL_DIR"
symfarm "${INSTALL_DIR}"
