#!/usr/bin/env bash
set -euo pipefail

ARCH="x86_64-linux"
INSTALL_DIR="$HOME/apps/zig"

# Fetch latest stable version and tarball URL
JSON=$(curl -fsSL https://ziglang.org/download/index.json)

VERSION=$(echo "$JSON" | jq -r '.latest')
TARBALL_URL=$(echo "$JSON" | jq -r ".\"$VERSION\".\"$ARCH\".tarball")

echo "Latest Zig version: $VERSION"
echo "Downloading: $TARBALL_URL"

curl -fsSL "$TARBALL_URL" -o zig.tar.xz

STAGING_DIR="${INSTALL_DIR}.new"
rm -rf "$STAGING_DIR"
mkdir -p "$STAGING_DIR"

tar -xJf zig.tar.xz -C "$STAGING_DIR" --strip-components=1
rm zig.tar.xz

# swap in only on success — preserves the old install if extraction fails
rm -rf "$INSTALL_DIR"
mv "$STAGING_DIR" "$INSTALL_DIR"
symfarm "${INSTALL_DIR}"
