[CmdletBinding()]
param(
    [Parameter(HelpMessage = "Run validation only without applying the configuration.")]
    [switch]$Test
)

$ErrorActionPreference = "Stop"

Write-Host "🚀 Starting PC Bootstrap Setup..." -ForegroundColor Cyan

# Check if winget is available
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Error "❌ winget is not installed or not in PATH. Please install it from the Microsoft Store."
    exit 1
}

Write-Host "🔍 Validating configuration..." -ForegroundColor Yellow
$validateArgs = @(
    "--file", "$PSScriptRoot\configuration.yaml",
    "--ignore-warnings"
)
& winget configure validate @validateArgs

if ($LASTEXITCODE -ne 0) {
    Write-Error "❌ Configuration validation failed."
    exit 1
}

# Exit early if this is a test run
if ($Test) {
    Write-Host "✅ Validation passed. (Test mode - no changes applied)" -ForegroundColor Green
    exit 0
}

Write-Host "🔍 Detecting dynamic paths..." -ForegroundColor Yellow
$userProfile = $env:USERPROFILE
$repoRootWin = $PSScriptRoot
$repoRootWsl = (wsl -e wslpath -u "$repoRootWin").Trim()

Write-Host "📍 User Profile: $userProfile" -ForegroundColor Gray
Write-Host "📍 WSL Repo Root: $repoRootWsl" -ForegroundColor Gray

Write-Host "🧩 Resolving configuration template..." -ForegroundColor Yellow
$configTemplate = Get-Content -Path ".\configuration.yaml" -Raw
$resolvedConfig = $configTemplate `
    -replace "\{\{USER_PROFILE\}\}", $userProfile.Replace('\', '\\') `
    -replace "\{\{REPO_ROOT_WSL\}\}", $repoRootWsl

$resolvedPath = ".\resolved-configuration.yaml"
$resolvedConfig | Out-File -FilePath $resolvedPath -Encoding utf8

Write-Host "🔧 Applying configuration..." -ForegroundColor Green
$applyArgs = @(
    "configure",
    "--file", $resolvedPath,
    "--accept-configuration-agreements",
    "--ignore-warnings"
)
& winget @applyArgs

# Cleanup temporary file
if (Test-Path $resolvedPath) {
    Remove-Item $resolvedPath
}

Write-Host "✅ Setup completed successfully!" -ForegroundColor Green
