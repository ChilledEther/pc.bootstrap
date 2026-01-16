<#
.SYNOPSIS
    Imports the custom MCP catalog natively via docker.exe.
#>
[cmdletBinding()]
param([switch]$Restore)
$ErrorActionPreference = 'Stop'

# 1. Resolve local path to mcp-servers.yaml (Windows style for docker.exe)
$LocalPath = Join-Path $PSScriptRoot "mcp-servers.yaml"
$LocalPathWin = if ($IsLinux) { wslpath -w "$LocalPath" } else { $LocalPath }

if ($Restore) {
    Write-Host "Restoring official Docker catalog..." -ForegroundColor Yellow
    & docker.exe mcp catalog reset
    Write-Host "Default catalog restored." -ForegroundColor Green
} else {
    Write-Host "Importing custom catalog from $LocalPathWin..." -ForegroundColor Cyan
    
    # Provide the catalog name 'custom-catalog' natively
    # If the user wants to replace the list, we recommend they select this catalog in Docker Desktop
    "custom-catalog" | & docker.exe mcp catalog import "$LocalPathWin"
    
    Write-Host "Success! Custom catalog imported as 'custom-catalog'." -ForegroundColor Green
}
