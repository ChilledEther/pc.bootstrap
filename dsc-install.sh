#!/bin/bash
set -e

TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

cd "$TMP_DIR"

echo "Downloading DSC v3.1.2..."
curl -L "https://github.com/PowerShell/DSC/releases/download/v3.1.2/DSC-3.1.2-x86_64-linux.tar.gz" -o dsc.tar.gz

echo "Extracting..."
tar -xzf dsc.tar.gz

echo "Installing to /usr/local/bin/dsc..."
if [ -f "/usr/local/bin/dsc" ]; then
    sudo rm -f /usr/local/bin/dsc
fi
sudo mv dsc /usr/local/bin/dsc
sudo chmod +x /usr/local/bin/dsc

echo "Verifying installation..."
dsc --version