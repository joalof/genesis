#!/usr/bin/env bash

# seems bugged
# curl -sS https://starship.rs/install.sh | sh

# build from source instead
git clone https://github.com/starship/starship.git
cd starship
cargo install --locked --path .
cd ..
rm -rf starship/
