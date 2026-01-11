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

# Functional check to catch "File cannot be accessed" (1920) or "Invalid directory" (267) errors early
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
# Switch to a local Windows directory to avoid 'Invalid Directory' errors when running from WSL
Push-Location $env:TEMP
$dscOutput = dsc config test --file $resolvedPath 2>&1 | Out-String
Pop-Location

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
                
                $actual = $resource.result.actualState
                $desired = $resource.result.desiredState
                $diffs = $resource.result.differingProperties
                
                # Unwrap 'properties' if present
                if ($actual.properties) { $actual = $actual.properties }
                if ($desired.properties) { $desired = $desired.properties }
                
                if ($desired) {
                    foreach ($prop in $desired.PSObject.Properties.Name) {
                        $desiredVal = $desired.$prop
                        
                        # Check if this property is explicitly listed in the 'differingProperties' array
                        $isDiff = $diffs -contains $prop
                        
                        if ($isDiff) {
                            # Try to get actual value, but fall back to 'Unknown' if the provider doesn't return it during test
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
    Write-Host ""
    Write-Host $dscOutput -ForegroundColor Gray
    Write-Host ""
    if (Test-Path $resolvedPath) { Remove-Item $resolvedPath }
    Write-Error "Test phase failed. Cannot proceed safely."
    exit 1
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
Push-Location $env:TEMP
$setConfigOutput = dsc config set --file $resolvedPath 2>&1 | Out-String
Pop-Location

# Parse the set output to verify success
$setSuccess = $true
if ($setConfigOutput -match '\"hadErrors\":\s*true') {
    $setSuccess = $false
} elseif ($LASTEXITCODE -ne 0) {
    $setSuccess = $false
}

# Cleanup temporary file before potentially exiting
if (Test-Path $resolvedPath) {
    Remove-Item $resolvedPath
}

if (-not $setSuccess) {
    Write-Host "❌ Apply failed! See error output below:" -ForegroundColor Red
    Write-Host ""
    Write-Host $setConfigOutput -ForegroundColor Gray
    Write-Host ""
    Write-Error "Configuration apply failed. Please review the errors above."
    exit 1
}

Write-Host "✅ Setup completed successfully!" -ForegroundColor Green
