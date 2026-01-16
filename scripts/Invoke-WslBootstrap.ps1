[CmdletBinding()]
param(
    [Parameter(Mandatory, HelpMessage = "Absolute path to the repository root.")]
    [string]$RepoPath
)

$ErrorActionPreference = "Stop"

Write-Host "🚀 Initializing WSL Interior Environment..." -ForegroundColor Cyan

$Tools = @{
    Apt = @("git", "powershell", "curl", "wget", "build-essential", "yq")
    Brew = @("bun", "uv", "gh", "topgrade", "opentofu", "node", "go")
}

# 1. Handle APT Tools
Write-Host "📦 Installing APT packages: $($Tools.Apt -join ', ')" -ForegroundColor Green
sudo apt-get update
$aptArgs = @("-y") + $Tools.Apt
sudo apt-get install @aptArgs

# 2. Handle Brew (Core Installation)
if (-not (Test-Path "/home/linuxbrew/.linuxbrew/bin/brew")) {
    Write-Host "🍺 Installing Homebrew..." -ForegroundColor Yellow
    $env:NONINTERACTIVE = 1
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

# Setup Brew environment for this session
$brewBinary = "/home/linuxbrew/.linuxbrew/bin/brew"
$env:PATH = "/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:" + $env:PATH

# 3. Handle Brew Tools
Write-Host "🍺 Installing Brew tools: $($Tools.Brew -join ', ')" -ForegroundColor Green
$brewArgs = @("install") + $Tools.Brew
& $brewBinary @brewArgs

# 4. Global Path Persistence
Write-Host "📝 Setting up global profile persistence..." -ForegroundColor Green
$profileContent = @"
# Add Homebrew to Path
if [ -d "/home/linuxbrew/.linuxbrew" ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi
"@

# Write to /etc/profile.d/ using sudo
$profileContent | sudo tee "/etc/profile.d/bootstrap.sh" > /dev/null
sudo chmod +x /etc/profile.d/bootstrap.sh

# 5. Create Onboarding Marker
Write-Host "🔖 Creating onboarding marker..." -ForegroundColor Green
"Bootstrapped on $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" | sudo tee "/root/.wsl-bootstrapped" > /dev/null

Write-Host "✨ WSL Interior Bootstrap Complete!" -ForegroundColor Cyan
