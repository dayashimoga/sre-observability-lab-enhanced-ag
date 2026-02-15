
# deploy_stack.ps1 - Windows Entry Point
# Run as Administrator

$ErrorActionPreference = "Stop"

Write-Host "Starting SRE Observability Lab Deployment..." -ForegroundColor Cyan

# 1. Check WSL
if (-not (Get-Command "wsl" -ErrorAction SilentlyContinue)) {
    Write-Error "WSL is not installed. Run 'wsl --install' and restart."
}

# 2. Check regarding functional Ubuntu
$ubuntuExists = $false
try {
    wsl -d Ubuntu true 2>$null
    if ($LASTEXITCODE -eq 0) {
        $ubuntuExists = $true
    }
} catch {
    $ubuntuExists = $false
}

if (-not $ubuntuExists) {
    Write-Host "Ubuntu distro not found or not working." -ForegroundColor Yellow
    
    Write-Host "Installing Ubuntu..." -ForegroundColor Cyan
    wsl --install -d Ubuntu
    
    Write-Host "-----------------------------------------------------" -ForegroundColor Yellow
    Write-Host "Ubuntu installation started."
    Write-Host "If a window opens, complete the setup."
    Write-Host "Then RERUN this script."
    Write-Host "-----------------------------------------------------" -ForegroundColor Yellow
    exit
} else {
    Write-Host "Ubuntu distribution detected." -ForegroundColor Green
}

# 3. Execute Linux Script
Write-Host "Invoking Linux Deployment Script in Ubuntu..." -ForegroundColor Cyan

$linuxScript = "scripts/deploy_stack.sh"

if (Test-Path $linuxScript) {
    # Convert line endings manually to avoid complex pipeline issues
    $txt = [System.IO.File]::ReadAllText("$PWD\$linuxScript")
    $txt = $txt.Replace("`r`n", "`n")
    [System.IO.File]::WriteAllText("$PWD\$linuxScript", $txt)
    
    # Run in Ubuntu
    wsl -d Ubuntu bash scripts/deploy_stack.sh
} else {
    Write-Error "File scripts/deploy_stack.sh not found."
}
