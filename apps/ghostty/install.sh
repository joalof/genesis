if [[ -n ${WSL_DISTRO_NAME} ]]; then
    echo "WSL detected -> we use windows native Wezterm instead"
    exit 0
fi
origin=$pwd

# then install ghostty
wget https://github.com/ghostty-org/ghostty/releases/download/tip/ghostty-source.tar.gz
tar xf ghostty-source.tar.gz
cd ghostty-source

zig build -p $HOME/.local -Doptimize=ReleaseFast
# TODO install binary
cd $origin
