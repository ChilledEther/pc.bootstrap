[cmdletBinding()]
param([switch]$Restore)

if ($Restore) {
    docker.exe mcp catalog reset
} else {
    $path = Join-Path $PSScriptRoot "mcp-servers.yaml"
    if ($IsLinux) { $path = wslpath -w $path }
    
    docker.exe mcp catalog import $PSScriptRoot/custom-mcps.yaml
}
