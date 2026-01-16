#!/bin/bash
# scripts/bootstrap-linux.sh
# This script handles the initial "chicken and egg" problem by installing 
# PowerShell and DSC before handing off to the PowerShell-based bootstrap logic.

set -e

# Get repo root absolute path
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "🚀 Starting Linux Bootstrap..."

# 1. Check/Install PowerShell (Required for Invoke-WslBootstrap.ps1)
if ! command -v pwsh &> /dev/null; then
    echo "📥 Installing PowerShell..."
    sudo apt-get update
    sudo apt-get install -y wget apt-transport-https software-properties-common
    
    # Get Ubuntu version
    source /etc/os-release
    
    # Download and register the Microsoft repository GPG keys
    wget -q "https://packages.microsoft.com/config/ubuntu/${VERSION_ID}/packages-microsoft-prod.deb"
    sudo dpkg -i packages-microsoft-prod.deb
    rm packages-microsoft-prod.deb
    
    # Update and install
    sudo apt-get update
    sudo apt-get install -y powershell
    echo "✅ PowerShell installed."
else
    echo "✅ PowerShell is already installed."
fi

# 2. Check/Install DSC v3 (Required for interior configuration)
if ! command -v dsc &> /dev/null; then
    echo "📥 Installing DSC v3.1.2..."
    TMP_DIR=$(mktemp -d)
    
    curl -L "https://github.com/PowerShell/DSC/releases/download/v3.1.2/DSC-3.1.2-x86_64-linux.tar.gz" -o "$TMP_DIR/dsc.tar.gz"
    tar -xzf "$TMP_DIR/dsc.tar.gz" -C "$TMP_DIR"
    
    sudo mv "$TMP_DIR/dsc" /usr/local/bin/dsc
    sudo chmod +x /usr/local/bin/dsc
    
    rm -rf "$TMP_DIR"
    echo "✅ DSC installed."
else
    echo "✅ DSC is already installed."
fi

# 3. Hand off to the PowerShell bootstrap script
echo "⚡ Transferring execution to Invoke-WslBootstrap.ps1..."
pwsh -File "$REPO_ROOT/scripts/Invoke-WslBootstrap.ps1" -RepoPath "$REPO_ROOT"

echo "🎉 Linux Bootstrap sequence complete!"
