
# access_ui.ps1 - Start Port Forwarding for ArgoCD
# Run as Administrator or User

Write-Host "Starting Port Forward for ArgoCD..." -ForegroundColor Cyan
Write-Host "Checking if WSL is running..."

if (-not (Get-Command "wsl" -ErrorAction SilentlyContinue)) {
    Write-Error "WSL not found."
}

# Check if ArgoCD pod is ready
Write-Host "Verifying ArgoCD Server status..."
$podStatus = wsl -d Ubuntu kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o jsonpath="{.items[0].status.phase}" 2>$null

if ($podStatus -ne "Running") {
    Write-Host "ArgoCD Server is not ready yet (Status: $podStatus). Waiting..." -ForegroundColor Yellow
    wsl -d Ubuntu kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=60s
}

Write-Host "ArgoCD is Ready." -ForegroundColor Green
Write-Host "--------------------------------------------------------"
Write-Host "Access URL: https://localhost:8080"
Write-Host "Username:   admin"

# Get Password
$password = wsl -d Ubuntu kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | wsl -d Ubuntu base64 -d
Write-Host "Password:   $password"
Write-Host "--------------------------------------------------------"
Write-Host "PRESS CTRL+C TO STOP THE SERVER" -ForegroundColor Yellow

# Start Port Forward
wsl -d Ubuntu kubectl port-forward svc/argocd-server -n argocd 8080:443 --address 0.0.0.0
