#!/usr/bin/env bash
GITHUB_USERNAME="joalof"
sh -c "$(curl -fsLS get.chezmoi.io)"
mv bin/chezmoi ~/.local/bin
rm -r bin/
~/.local/bin/chezmoi init --apply $GITHUB_USERNAME
