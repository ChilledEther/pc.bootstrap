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

# Check if winget is available and responsive
Write-Host "🔍 Checking WinGet health..." -ForegroundColor Yellow
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Error "❌ WinGet is not installed or not in PATH. Please install it from the Microsoft Store."
    exit 1
}

# Functional check for WinGet
try {
    $wingetCheck = winget --version 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "WinGet returned exit code $LASTEXITCODE"
    }
    Write-Host "✅ WinGet is responsive (v$(($wingetCheck -join '').Trim()))" -ForegroundColor Green
} catch {
    Write-Host "❌ WinGet health check failed!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Error details: $_" -ForegroundColor Gray
    Write-Host ""
    Write-Host "💡 TIP: This often happens in Admin terminals or when running from WSL paths." -ForegroundColor Cyan
    Write-Host "1. Try running: 'winget --version' directly to see the error." -ForegroundColor Cyan
    Write-Host "2. Try repairing 'App Installer' in Windows Settings." -ForegroundColor Cyan
    exit 1
}

# Resolve template placeholders
Write-Host "🔍 Detecting dynamic paths..." -ForegroundColor Yellow
$userProfile = $env:USERPROFILE
$repoRootWin = Resolve-Path "$PSScriptRoot\.."
$repoRootWsl = (wsl -e wslpath -u "$repoRootWin").Trim()

Write-Host "📍 User Profile: $userProfile" -ForegroundColor Gray
Write-Host "📍 WSL Repo Root: $repoRootWsl" -ForegroundColor Gray

Write-Host "🧩 Resolving configuration template..." -ForegroundColor Yellow
$configPath = Join-Path $repoRootWin "configuration.yaml"
$configTemplate = Get-Content -Path $configPath -Raw
$resolvedConfig = $configTemplate `
    -replace "\{\{USER_PROFILE\}\}", $userProfile.Replace('\', '\\') `
    -replace "\{\{REPO_ROOT_WSL\}\}", $repoRootWsl

$resolvedPath = Join-Path $repoRootWin "resolved-configuration.yaml"
$resolvedConfig | Out-File -FilePath $resolvedPath -Encoding utf8

# Test configuration and show drift
Write-Host "📋 Checking configuration drift..." -ForegroundColor Cyan
Write-Host ""

# Run DSC test using splatting
Push-Location $env:TEMP
$testArgs = @(
    "config", "test",
    "--file", $resolvedPath
)
$dscOutput = dsc @testArgs 2>&1 | Out-String
Pop-Location

if ($dscOutput -match '\"inDesiredState\"') {
    $jsonStart = $dscOutput.IndexOf('{')
    $jsonOutput = if ($jsonStart -ge 0) { $dscOutput.Substring($jsonStart) } else { $dscOutput }
    
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
                
                $actual = $resource.result.actualState
                $desired = $resource.result.desiredState
                $diffs = $resource.result.differingProperties
                
                if ($actual.properties) { $actual = $actual.properties }
                if ($desired.properties) { $desired = $desired.properties }
                
                if ($desired) {
                    foreach ($prop in $desired.PSObject.Properties.Name) {
                        $desiredVal = $desired.$prop
                        $isDiff = $diffs -contains $prop
                        
                        if ($isDiff) {
                            $actualVal = if ($actual.$prop -ne $null) { $actual.$prop } else { "Unknown" }
                            Write-Host "    - $($prop): '$($actualVal)' -> Desired: '$($desiredVal)'" -ForegroundColor Gray
                        }
                    }
                }
            }
        }
    } catch {
        Write-Host "⚠️ JSON parse error: $_" -ForegroundColor Red
        Write-Host $dscOutput
    }
} else {
    Write-Host "❌ DSC test phase failed to execute correctly!" -ForegroundColor Red
    if (Test-Path $resolvedPath) { Remove-Item $resolvedPath }
    Write-Error "Test phase failed. Cannot proceed safely."
}

# Exit early if test mode
if ($Test) {
    if (Test-Path $resolvedPath) { Remove-Item $resolvedPath }
    Write-Host "✅ Test complete. (No changes applied)" -ForegroundColor Green
    exit 0
}

# Prompt for confirmation
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
Push-Location $env:TEMP
$setArgs = @(
    "config", "set",
    "--file", $resolvedPath
)
$setConfigOutput = dsc @setArgs 2>&1 | Out-String
Pop-Location

# Verify success
$setSuccess = $true
if ($setConfigOutput -match '\"hadErrors\":\s*true' -or $LASTEXITCODE -ne 0) {
    $setSuccess = $false
}

if (Test-Path $resolvedPath) { Remove-Item $resolvedPath }

if (-not $setSuccess) {
    Write-Host "❌ Apply failed! See error output below:" -ForegroundColor Red
    Write-Host $setConfigOutput -ForegroundColor Gray
    Write-Error "Configuration apply failed. Please review the errors above."
}

Write-Host "✨ Setup completed successfully!" -ForegroundColor Green
