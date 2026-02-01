origin=$pwd

# then install ghostty
wget https://github.com/ghostty-org/ghostty/releases/download/tip/ghostty-source.tar.gz
tar xf ghostty-source.tar.gz
cd ghostty-source

zig build -p $HOME/.local -Doptimize=ReleaseFast
cd $origin
