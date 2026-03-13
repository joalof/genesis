#!/usr/bin/env bash
set -euo pipefail
# download tip

if [[ ! -f ghostty-source.tar.gz ]] || [[ $(find ghostty-source.tar.gz -mmin +60 2>/dev/null) ]]; then
    wget https://github.com/ghostty-org/ghostty/releases/download/tip/ghostty-source.tar.gz
fi
src_dir=$(tar tzf ghostty-source.tar.gz 2>/dev/null | head -1 | cut -d/ -f1 || true)
[[ -n "${src_dir}" ]] || { echo "ERROR: could not determine source directory from tarball"; exit 1; }
tar xf ghostty-source.tar.gz
rm ghostty-source.tar.gz

# install
install_dir=$HOME/apps/ghostty
mkdir -p "${install_dir}"
zig_extra_flags=()
if ! apt-get install -y gtk4-layer-shell 2>/dev/null; then
    zig_extra_flags+=("-fno-sys=gtk4-layer-shell")
fi
(
    cd "${src_dir}"
    zig build -p "${install_dir}" -Doptimize=ReleaseFast "${zig_extra_flags[@]}"
)
rm -rf "${src_dir}"
symfarm "${install_dir}"
