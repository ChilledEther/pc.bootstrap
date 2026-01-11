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

# Test configuration and show drift
Write-Host "📋 Checking configuration drift..." -ForegroundColor Cyan
Write-Host ""

# Run DSC test using the resolved configuration directly
# Native DSC v3 handles valid YAML directly
$dscOutput = dsc config test --file $resolvedPath 2>&1 | Out-String

if ($dscOutput -match '\"inDesiredState\"') {
    # Parse JSON and show drift status
    # Extract JSON portion (skip any WARN/ERROR lines before the JSON)
    $jsonStart = $dscOutput.IndexOf('{')
    if ($jsonStart -ge 0) {
        $jsonOutput = $dscOutput.Substring($jsonStart)
    } else {
        $jsonOutput = $dscOutput
    }
    
    try {
        $results = $jsonOutput | ConvertFrom-Json
        foreach ($resource in $results.results) {
            $name = $resource.name
            $type = $resource.type
            $inDesiredState = $resource.result.inDesiredState
            
            if ($inDesiredState -eq $true) {
                Write-Host "✅ $type [$name]" -ForegroundColor Green
            } else {
                Write-Host "⚠️  $type [$name] - DRIFT DETECTED" -ForegroundColor Yellow
            }
        }
    } catch {
        Write-Host "⚠️ JSON parse error: $_" -ForegroundColor Red
        Write-Host $dscOutput
    }
} else {
    Write-Host "⚠️  DSC test failed. Error output:" -ForegroundColor Yellow
    Write-Host $dscOutput -ForegroundColor Gray
}

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

# Apply configuration using native DSC
Write-Host "🔧 Applying configuration..." -ForegroundColor Green
dsc config set --file $resolvedPath

# Cleanup temporary file
if (Test-Path $resolvedPath) {
    Remove-Item $resolvedPath
}

Write-Host "✅ Setup completed successfully!" -ForegroundColor Green
