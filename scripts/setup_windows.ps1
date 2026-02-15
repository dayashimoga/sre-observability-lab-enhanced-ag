
# setup_windows.ps1 - Configure WSL2 Resources
# Run as Administrator

Write-Host "🚀 Setting up Windows environment for SRE Observability Lab..." -ForegroundColor Cyan

# 1. Create .wslconfig
$wslConfigPath = "$env:UserProfile\.wslconfig"
$wslConfigContent = @"
[wsl2]
memory=12GB
processors=4
swap=4GB
localhostForwarding=true
"@

Write-Host "📝 Writing .wslconfig to $wslConfigPath..."
Set-Content -Path $wslConfigPath -Value $wslConfigContent

# 2. Check for WSL
if (Get-Command "wsl" -ErrorAction SilentlyContinue) {
    Write-Host "✅ WSL is installed." -ForegroundColor Green
} else {
    Write-Host "⚠️ WSL not found. Please run 'wsl --install' and restart." -ForegroundColor Yellow
    exit 1
}

# 3. Instructions
Write-Host "--------------------------------------------------------" -ForegroundColor Cyan
Write-Host "🎉 Configuration Complete!" -ForegroundColor Green
Write-Host "PLEASE RESTART WSL FOR CHANGES TO TAKE EFFECT:" -ForegroundColor Yellow
Write-Host "  wsl --shutdown"
Write-Host "--------------------------------------------------------"
Write-Host "Next Step: Open your WSL terminal (e.g. Ubuntu) and run:"
Write-Host "  bash scripts/setup_k3s.sh" -ForegroundColor Cyan
