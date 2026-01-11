$ErrorActionPreference = "Stop"

Write-Host "🚀 Starting PC Bootstrap Setup..." -ForegroundColor Cyan

# Check if winget is available
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Error "❌ winget is not installed or not in PATH. Please install it from the Microsoft Store."
    exit 1
}

Write-Host "🔍 Validating configuration..." -ForegroundColor Yellow
$validateArgs = @(
    "configure",
    "validate",
    "--file", ".\configuration.yaml"
)
& winget @validateArgs

if ($LASTEXITCODE -ne 0) {
    Write-Error "❌ Configuration validation failed."
    exit 1
}

Write-Host "🔍 Detecting dynamic paths..." -ForegroundColor Yellow
$userProfile = $env:USERPROFILE
$repoRootWin = $PSScriptRoot
$repoRootWsl = (wsl -e wslpath -u "$repoRootWin").Trim()

Write-Host "📍 User Profile: $userProfile" -ForegroundColor Gray
Write-Host "📍 WSL Repo Root: $repoRootWsl" -ForegroundColor Gray

Write-Host "🔧 Applying configuration..." -ForegroundColor Green
$applyArgs = @(
    "configure",
    "--file", ".\configuration.yaml",
    "--accept-configuration-agreements",
    "--parameter", "UserProfile=$userProfile",
    "--parameter", "RepoRootLinux=$repoRootWsl"
)
& winget @applyArgs

Write-Host "✅ Setup completed successfully!" -ForegroundColor Green
