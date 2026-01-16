$ErrorActionPreference = "Stop"

Write-Host "🔍 Detecting platform..." -ForegroundColor Yellow

if ($IsWindows) {
    Write-Error "❌ This installer is currently intended for Linux/WSL. Windows installation of DSC v3 should be done via Direct Download or WinGet when available."
    exit 1
}

$version = "3.1.2"
$arch = "x86_64"
$url = "https://github.com/PowerShell/DSC/releases/download/v$version/DSC-$version-$arch-linux.tar.gz"
$destPath = "/usr/local/bin/dsc"

Write-Host "📥 Downloading DSC v$version..." -ForegroundColor Cyan
$tmpDir = New-Item -ItemType Directory -Path "$env:TEMP/dsc-install" -Force
Push-Location $tmpDir

try {
    $downloadArgs = @(
        "-L", $url,
        "-o", "dsc.tar.gz"
    )
    curl.exe @downloadArgs

    Write-Host "📦 Extracting..." -ForegroundColor Cyan
    tar -xzf dsc.tar.gz

    Write-Host "🚀 Installing to $destPath..." -ForegroundColor Green
    if (Test-Path $destPath) {
        $null = sudo rm -f $destPath
    }
    $null = sudo mv dsc $destPath
    $null = sudo chmod +x $destPath

    Write-Host "✅ Verifying installation..." -ForegroundColor Green
    & $destPath --version
}
finally {
    Pop-Location
    Remove-Item -Path $tmpDir -Recurse -Force
}

Write-Host "🎉 DSC installation complete!" -ForegroundColor Green
