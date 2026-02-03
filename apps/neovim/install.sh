#!/usr/bin/env bash
cd ~/.local/src/
git clone https://github.com/neovim/neovim.git
cd neovim/
git checkout nightly
INSTALL_DIR="$HOME/apps/neovim"
rm -r INSTALL_DIR="$HOME/apps/neovim"
mkdir INSTALL_DIR="$HOME/apps/neovim"
make CMAKE_BUILD_TYPE=Release CMAKE_INSTALL_PREFIX=${INSTALL_DIR}
make CMAKE_BUILD_TYPE=Release CMAKE_INSTALL_PREFIX=${INSTALL_DIR} install
symfarm ${INSTALL_DIR}
