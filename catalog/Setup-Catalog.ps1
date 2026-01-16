[cmdletBinding()]
param([switch]$Restore)

if ($Restore) {
    docker mcp catalog reset
} else {
    $yamlPath = Join-Path $PSScriptRoot "custom-mcps.yaml"
    $importPath = $yamlPath

    if ($IsLinux) { 
        $importPath = wslpath -w $yamlPath 
    }
    
    docker mcp catalog import $importPath

    # Parse servers keys using yq and install each server
    $servers = @(yq '.servers | keys | .[]' $yamlPath)
    
    foreach ($server in $servers) {
        if (-not [string]::IsNullOrWhiteSpace($server)) {
            Write-Host "Installing MCP server: $server"
            docker mcp server enable $server
        }
    }
}