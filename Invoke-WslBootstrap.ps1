param(
    [Parameter(Mandatory)]
    [string]$RepoPath
)

$ErrorActionPreference = "Stop"

$configPath = "$RepoPath/wsl-tools.yaml"

Write-Host "🚀 Initializing WSL Interior Environment..." -ForegroundColor Cyan

# 1. Ensure yq is available
if (-not (Get-Command yq -ErrorAction SilentlyContinue)) {
    Write-Host "📥 Installing yq for config parsing..." -ForegroundColor Yellow
    apt-get update && apt-get install -y yq
}

# 2. Parse Config
$config = (yq eval -o=json . "$configPath" | ConvertFrom-Json)

# 3. Handle APT Tools
$aptTools = $config.tools.apt.PSObject.Properties | Where-Object { $_.Value.enabled -eq $true } | Select-Object -ExpandProperty Name
if ($aptTools) {
    Write-Host "📦 Installing APT packages: $($aptTools -join ', ')" -ForegroundColor Green
    apt-get update
    $null = apt-get install -y $aptTools
}

# 4. Handle Brew (Core Installation)
if (-not (Test-Path "/home/linuxbrew/.linuxbrew/bin/brew")) {
    Write-Host "🍺 Installing Homebrew..." -ForegroundColor Yellow
    export NONINTERACTIVE=1
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

# Source Brew for this session
$brewPath = "/home/linuxbrew/.linuxbrew/bin/brew"
function Invoke-Brew {
    param([string[]]$Arguments)
    $env:PATH = "/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:" + $env:PATH
    & $brewPath @Arguments
}

# 5. Handle Brew Tools
$brewTools = $config.tools.brew.PSObject.Properties | Where-Object { $_.Value.enabled -eq $true } | Select-Object -ExpandProperty Name
if ($brewTools) {
    Write-Host "🍺 Installing Brew tools: $($brewTools -join ', ')" -ForegroundColor Green
    $installArgs = @("install") + $brewTools
    Invoke-Brew -Arguments $installArgs
}

# 6. Global Path Persistence
Write-Host "📝 Setting up global profile persistence..." -ForegroundColor Green
$profileContent = @"
# Add Homebrew to Path
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
"@

$profileContent | Out-File -FilePath "/etc/profile.d/bootstrap.sh" -Encoding ascii
chmod +x /etc/profile.d/bootstrap.sh

Write-Host "✅ WSL Interior Bootstrap Complete!" -ForegroundColor Cyan
