<#
.SYNOPSIS
    Script to manage Docker MCP Catalog
    Location: /home/jjr/projects/repos/pc.bootstrap/catalog/setup-catalog.ps1
#>

[cmdletBinding()]
param (
    [switch]$Restore
)

$CatalogDir = $PSScriptRoot
if (-not $CatalogDir) { $CatalogDir = Get-Location }

$ConfigDir = Join-Path $env:USERPROFILE ".docker\mcp"
$ConfigFile = Join-Path $ConfigDir "docker-mcp.yaml"
$BackupFile = "$ConfigFile.bak"
$SourceCatalog = Join-Path $CatalogDir "mcp-servers.yaml"

function Install-CustomCatalog {
    Write-Host "--- Installing Custom Catalog ---" -ForegroundColor Cyan
    
    if (-not (Test-Path $SourceCatalog)) {
        Write-Error "Source catalog $SourceCatalog not found."
        return
    }

    if (-not (Test-Path $ConfigDir)) {
        New-Item -ItemType Directory -Path $ConfigDir -Force | Out-Null
    }

    if ((Test-Path $ConfigFile) -and (-not (Get-Item $ConfigFile).LinkType)) {
        Write-Host "Backing up existing catalog to $BackupFile"
        Copy-Item -Path $ConfigFile -Destination $BackupFile -Force
    }

    Write-Host "Linking $SourceCatalog to $ConfigFile"
    # Note: Requires administrative privileges for symlinks or Developer Mode enabled on Windows
    New-Item -ItemType SymbolicLink -Path $ConfigFile -Target $SourceCatalog -Force | Out-Null
    
    Write-Host "Success! Custom catalog is now active." -ForegroundColor Green
}

function Restore-DefaultCatalog {
    Write-Host "--- Restoring Default Catalog ---" -ForegroundColor Yellow
    
    if (Test-Path $ConfigFile) {
        Write-Host "Removing existing catalog file/link..."
        Remove-Item -Path $ConfigFile -Force
    }

    Write-Host "Running native bootstrap to restore defaults..."
    docker.exe mcp catalog bootstrap $ConfigFile
    
    Write-Host "Default catalog restored successfully." -ForegroundColor Green
}

if ($Restore) {
    Restore-DefaultCatalog
} else {
    Install-CustomCatalog
}
