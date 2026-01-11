[CmdletBinding()]
param(
    [Parameter(HelpMessage = "Run test only without applying.")]
    [switch]$Test,
    
    [Parameter(HelpMessage = "Skip confirmation prompt and apply changes immediately.")]
    [switch]$Force
)

$ErrorActionPreference = "Stop"

Write-Host "🚀 Starting PC Bootstrap Setup..." -ForegroundColor Cyan
if ($Test) {
    Write-Host "🧪 Running in TEST MODE (no changes will be applied)" -ForegroundColor Magenta
} elseif ($Force) {
    Write-Host "⚡ Running in FORCE MODE (skipping confirmation)" -ForegroundColor Yellow
}

# Check if winget is available
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Error "❌ winget is not installed or not in PATH. Please install it from the Microsoft Store."
    exit 1
}

# Resolve template placeholders
Write-Host "🔍 Detecting dynamic paths..." -ForegroundColor Yellow
$userProfile = $env:USERPROFILE
$repoRootWin = $PSScriptRoot
$repoRootWsl = (wsl -e wslpath -u "$repoRootWin").Trim()

Write-Host "📍 User Profile: $userProfile" -ForegroundColor Gray
Write-Host "📍 WSL Repo Root: $repoRootWsl" -ForegroundColor Gray

Write-Host "🧩 Resolving configuration template..." -ForegroundColor Yellow
$configTemplate = Get-Content -Path "$PSScriptRoot\configuration.yaml" -Raw
$resolvedConfig = $configTemplate `
    -replace "\{\{USER_PROFILE\}\}", $userProfile.Replace('\', '\\') `
    -replace "\{\{REPO_ROOT_WSL\}\}", $repoRootWsl

$resolvedPath = "$PSScriptRoot\resolved-configuration.yaml"
$resolvedConfig | Out-File -FilePath $resolvedPath -Encoding utf8

# Show what will be configured
Write-Host "📋 Resources to be configured:" -ForegroundColor Cyan
& winget configure test --file $resolvedPath --ignore-warnings

# Exit early if test mode
if ($Test) {
    if (Test-Path $resolvedPath) { Remove-Item $resolvedPath }
    Write-Host "✅ Test complete. (No changes applied)" -ForegroundColor Green
    exit 0
}

# Prompt for confirmation unless -Force is specified
if (-not $Force) {
    Write-Host ""
    $response = Read-Host "❓ Apply configuration now? (y/N)"
    if ($response -notmatch "^[Yy]$") {
        if (Test-Path $resolvedPath) { Remove-Item $resolvedPath }
        Write-Host "🚫 Cancelled. No changes applied." -ForegroundColor Yellow
        exit 0
    }
}

# Apply configuration
Write-Host "🔧 Applying configuration..." -ForegroundColor Green
& winget configure --file $resolvedPath --accept-configuration-agreements --ignore-warnings

# Cleanup temporary file
if (Test-Path $resolvedPath) {
    Remove-Item $resolvedPath
}

Write-Host "✅ Setup completed successfully!" -ForegroundColor Green
