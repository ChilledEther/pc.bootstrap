[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

Write-Host "🔍 Linting configuration.yaml..." -ForegroundColor Cyan

# Check if winget is available
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Error "❌ winget is not installed or not in PATH."
    exit 1
}

# Validate configuration syntax
& winget configure validate --file "$PSScriptRoot\configuration.yaml" --ignore-warnings

if ($LASTEXITCODE -gt 1) {
    Write-Error "❌ Linting failed with exit code $LASTEXITCODE."
    exit $LASTEXITCODE
}

Write-Host "✅ Configuration is valid." -ForegroundColor Green
