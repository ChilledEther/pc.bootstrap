$ErrorActionPreference = "Stop"

$setupPath = Join-Path $PSScriptRoot "scripts" "Invoke-WindowsSetup.ps1"

if (Test-Path $setupPath) {
    & $setupPath @args
} else {
    Write-Error "❌ Could not find Invoke-WindowsSetup.ps1 at $setupPath"
}
