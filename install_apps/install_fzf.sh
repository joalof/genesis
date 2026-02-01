cd ~/apps
git clone --depth 1 https://github.com/junegunn/fzf.git ~/apps/fzf
~/apps/fzf/install --no-bash --completion --key-bindings --no-update-rc --no-zsh
stow_app ~/apps/fzf
