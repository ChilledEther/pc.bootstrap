[CmdletBinding()]
param(
    [Parameter(HelpMessage = "Run test only without applying the configuration.")]
    [switch]$Test,
    
    [Parameter(HelpMessage = "Skip confirmation prompt and apply changes immediately.")]
    [switch]$Force
)

$ErrorActionPreference = "Stop"

Write-Host "🚀 Starting PC Bootstrap Setup..." -ForegroundColor Cyan
if ($Test) {
    Write-Host "🧪 Running in TEST MODE (no changes will be applied)" -ForegroundColor Magenta
}

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

# Exit code 1 = warnings only (acceptable with --ignore-warnings)
# Exit code > 1 = actual failure
if ($LASTEXITCODE -gt 1) {
    Write-Error "❌ Configuration validation failed with exit code $LASTEXITCODE."
    exit $LASTEXITCODE
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

# Always run test to show drift
Write-Host "🔬 Comparing configuration against current system state..." -ForegroundColor Cyan
$testArgs = @(
    "--file", $resolvedPath,
    "--ignore-warnings"
)
& winget configure test @testArgs

# Exit early if test mode
if ($Test) {
    if (Test-Path $resolvedPath) { Remove-Item $resolvedPath }
    Write-Host "✅ Test complete. (No changes applied)" -ForegroundColor Green
    exit 0
}

# Prompt for confirmation unless -Force is specified
if (-not $Force) {
    Write-Host ""
    $response = Read-Host "❓ Do you want to apply these changes? (y/N)"
    if ($response -notmatch "^[Yy]$") {
        if (Test-Path $resolvedPath) { Remove-Item $resolvedPath }
        Write-Host "🚫 Cancelled. No changes applied." -ForegroundColor Yellow
        exit 0
    }
}

Write-Host "🔧 Applying configuration..." -ForegroundColor Green
$applyArgs = @(
    "--file", $resolvedPath,
    "--accept-configuration-agreements",
    "--ignore-warnings"
)
& winget configure @applyArgs

# Cleanup temporary file
if (Test-Path $resolvedPath) {
    Remove-Item $resolvedPath
}

Write-Host "✅ Setup completed successfully!" -ForegroundColor Green
