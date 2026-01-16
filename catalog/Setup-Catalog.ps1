<#
.SYNOPSIS
    Simplified script to set up the Docker MCP Custom Catalog.
#>
[cmdletBinding()]
param([switch]$Restore)
$ErrorActionPreference = 'Stop'

# 1. Resolve Home Directories
if ($IsLinux) {
    # Get Windows home without UNC path warnings by changing to C: first
    $WinHome = cmd.exe /c "cd /d C:\ && echo %USERPROFILE%" | Select-Object -Last 1
    $WinHome = $WinHome.Trim()
    
    # Manual WSL path conversion
    if ($WinHome -match '^([A-Z]):(.*)') {
        $drive = $Matches[1].ToLower()
        $rest = $Matches[2] -replace '\\', '/'
        $WslHome = "/mnt/$drive$rest"
    } else {
        $WslHome = $WinHome -replace '\\', '/'
    }
} else {
    $WinHome = $env:USERPROFILE
    $WslHome = $WinHome
}

$TargetFileWSL = "$WslHome/.docker/mcp/docker-mcp.yaml"
$TargetFileWin = "$WinHome\.docker\mcp\docker-mcp.yaml"

if ($Restore) {
    Write-Host "Restoring default catalog..." -ForegroundColor Yellow
    if (Test-Path $TargetFileWSL) { Remove-Item $TargetFileWSL -Force }
    & docker.exe mcp catalog bootstrap "$TargetFileWin"
    Write-Host "Default catalog restored." -ForegroundColor Green
} else {
    Write-Host "Installing custom catalog..." -ForegroundColor Cyan
    $Source = Join-Path $PSScriptRoot "mcp-servers.yaml"
    
    $Dir = Split-Path $TargetFileWSL
    if (-not (Test-Path $Dir)) { New-Item -ItemType Directory -Path $Dir -Force | Out-Null }
    
    Copy-Item -Path $Source -Destination $TargetFileWSL -Force
    Write-Host "Custom catalog installed to $TargetFileWSL" -ForegroundColor Green
}
