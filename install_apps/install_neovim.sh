origin=$PWD
cd ~/.local/src/
git clone https://github.com/neovim/neovim.git
cd neovim/
make CMAKE_BUILD_TYPE=Release CMAKE_INSTALL_PREFIX=$HOME/apps/neovim
make CMAKE_BUILD_TYPE=Release CMAKE_INSTALL_PREFIX=$HOME/apps/neovim install
cd $origin
