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
# DSC CLI requires resourceId() syntax for dependsOn, but WinGet uses simple names
# We transform on-the-fly for testing, keeping the source file WinGet-compatible
Write-Host "📋 Checking configuration drift..." -ForegroundColor Cyan
Write-Host ""

# Build name-to-type map from the config
$nameToType = @{}
$configLines = $resolvedConfig -split "`n"
$currentName = $null
foreach ($line in $configLines) {
    if ($line -match '^\s*-?\s*name:\s*(.+)$') {
        $currentName = $matches[1].Trim()
    }
    if ($currentName -and $line -match '^\s*type:\s*(.+)$') {
        $nameToType[$currentName] = $matches[1].Trim()
        $currentName = $null
    }
}

# Transform dependsOn from simple names to resourceId() syntax for DSC
$dscConfig = $resolvedConfig
foreach ($name in $nameToType.Keys) {
    $type = $nameToType[$name]
    # Replace "name" with "[resourceId('type', 'name')]" in dependsOn contexts
    $dscConfig = $dscConfig -replace "(?<=dependsOn:\s*\n(?:\s*-\s*.*\n)*\s*-\s*)""$name""", """[resourceId('$type', '$name')]"""
}

# Remove resources that DSC CLI can't handle (parser issues with multiline content)
# These will still be applied by WinGet, just not drift-tested
$dscConfig = $dscConfig -replace '(?ms)^\s*-\s*name:\s*\S+\s*\n\s*type:\s*PSDesiredStateConfiguration/File.*?(?=^\s*-\s*name:|\z)', ''

$dscTestPath = "$PSScriptRoot\dsc-test-configuration.yaml"
$dscConfig | Out-File -FilePath $dscTestPath -Encoding utf8

# Try DSC test first (shows actual drift), fallback to WinGet test
# TODO: When WinGet improves drift detection, this can be simplified
$dscOutput = & dsc config test --file $dscTestPath 2>&1 | Out-String

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
    # Fallback to WinGet test (no drift info, just resource list)
    Write-Host "⚠️  DSC test failed. Error output:" -ForegroundColor Yellow
    Write-Host $dscOutput -ForegroundColor Gray
    Write-Host ""
    Write-Host "Falling back to WinGet test (no drift detection)..." -ForegroundColor Yellow
    & winget configure test --file $resolvedPath --ignore-warnings
}

# Cleanup DSC test file
if (Test-Path $dscTestPath) { Remove-Item $dscTestPath }
Write-Host ""

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
