#!/usr/bin/env bash

# didn't work 
# curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash

# install manually
ARCHIVE="nvm.tar.gz"
curl -L https://github.com/nvm-sh/nvm/archive/refs/tags/$(basename "$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/nvm-sh/nvm/releases/latest)").tar.gz -o $ARCHIVE
TOPDIR=$(tar tzf nvm.tar.gz | head -1 | cut -d/ -f1)
tar xf $ARCHIVE
mkdir -p ~/apps/nvm 2>/dev/null
mv "$TOPDIR/nvm.sh" "$TOPDIR/bash_completion" ~/apps/nvm
nvm install --lts
rm -r $TOPDIR $ARCHIVE
