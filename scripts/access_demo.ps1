
# access_demo.ps1 - Start Port Forwarding for Demo App
# Run as Administrator or User

Write-Host "Starting Port Forward for Demo App..." -ForegroundColor Cyan
Write-Host "Checking if WSL is running..."

if (-not (Get-Command "wsl" -ErrorAction SilentlyContinue)) {
    Write-Error "WSL not found."
}

# Check if Demo App pod is ready
Write-Host "Verifying Demo App status..."
$podStatus = wsl -d Ubuntu kubectl get pods -n demo -l app.kubernetes.io/name=demo-app -o jsonpath="{.items[0].status.phase}" 2>$null

if ($podStatus -ne "Running") {
    Write-Host "Demo App is not ready yet (Status: $podStatus). Waiting..." -ForegroundColor Yellow
    wsl -d Ubuntu kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=demo-app -n demo --timeout=60s
}

Write-Host "Demo App is Ready." -ForegroundColor Green
Write-Host "--------------------------------------------------------"
Write-Host "Access URL: http://localhost:8081"
Write-Host "--------------------------------------------------------"
Write-Host "PRESS CTRL+C TO STOP" -ForegroundColor Yellow

# Start Port Forward (Port 8081 locally -> Port 80 in pod)
wsl -d Ubuntu kubectl port-forward svc/demo-app -n demo 8081:80 --address 0.0.0.0
