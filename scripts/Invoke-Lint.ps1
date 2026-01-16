[CmdletBinding()]
param(
    [Parameter(HelpMessage = "The configuration file to lint.")]
    [string]$File = "configuration.yaml"
)

$ErrorActionPreference = "Stop"

$filePath = Resolve-Path (Join-Path $PSScriptRoot ".." $File)

Write-Host "🔍 Linting DSC configuration: $File..." -ForegroundColor Cyan

# Check for existence of dsc
if (-not (Get-Command dsc -ErrorAction SilentlyContinue)) {
    Write-Error "❌ DSC command not found. Please install it using .\setup.ps1 or scripts/Install-Dsc.ps1"
}

try {
    # Run a test to validate syntax
    $lintArgs = @(
        "config", "test",
        "--file", $filePath
    )
    # We don't care about the result, just if it errors on syntax
    $null = dsc @lintArgs 2>&1
    Write-Host "✅ Configuration syntax is valid." -ForegroundColor Green
} catch {
    Write-Host "❌ Configuration syntax error!" -ForegroundColor Red
    Write-Host $_ -ForegroundColor Gray
    exit 1
}
