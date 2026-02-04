#!/usr/bin/env bash
set -euo pipefail
# download tip
cd ~/.local/src
wget https://github.com/ghostty-org/ghostty/releases/download/tip/ghostty-source.tar.gz
tar xf ghostty-source.tar.gz
rm ghostty-source.tar.gz
cd ghostty-source

# install
install_dir=$HOME/apps/ghostty
mkdir -p "${install_dir}"
zig build -p "${install_dir}" -Doptimize=ReleaseFast
symfarm "${install_dir}"
