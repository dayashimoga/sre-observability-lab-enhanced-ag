
# Setup Guide: k3s on Windows for SRE Observability Lab

This guide details how to set up a production-grade Kubernetes environment on Windows using WSL2 and k3s, suitable for running the full observability stack.

## Prerequisites

1.  **Windows 10/11 Pro or Enterprise** recommended.
2.  **WSL2 Enabled**:
    *   Open PowerShell as Administrator: `wsl --install`
    *   Restart if prompted.
3.  **Docker Desktop** (Optional but recommended for image building) OR **Rancher Desktop**.
4.  **Hardware Resources**:
    *   Minimum: 4 vCPUs, 8GB RAM.
    *   Recommended: 4+ vCPUs, 16GB+ RAM (for full stack: Splunk, Dynatrace, HA Prometheus).

## Automated Setup (Recommended)

### 1. Windows Setup
Open PowerShell as Administrator and run:
```powershell
./scripts/setup_windows.ps1
wsl --shutdown
```

### 2. WSL Environment Setup
Open your WSL terminal (Ubuntu) and run from the repo root:
```bash
sudo bash scripts/setup_k3s.sh
source ~/.bashrc
```

## Manual Setup (Legacy)

### Option A: Rancher Desktop

1.  Download and install [Rancher Desktop](https://rancherdesktop.io/).
2.  **Kubernetes Settings**:
    *   Container Engine: **dockerd (moby)**
    *   Kubernetes Version: Latest stable (e.g., v1.28.x+).
    *   **WSL Integration**: Ensure your default distro (e.g., Ubuntu) is checked.
3.  **Traefik Disabling** (Important):
    *   We will use Nginx Ingress Controller.
    *   Go to `Preferences` -> `Kubernetes` -> Uncheck "Enable Traefik".
4.  **Resources**:
    *   Go to `.wslconfig` (see below) to ensure sufficient resources are allocated to the Rancher Desktop VM.

## Option B: k3s via WSL2 (Manual)

1.  Install a Linux distro from Microsoft Store (e.g., Ubuntu 22.04 LTS).
2.  Open Ubuntu terminal.
3.  **Install k3s**:
    ```bash
    curl -sfL https://get.k3s.io | sh -s - --disable traefik --write-kubeconfig-mode 644
    ```
4.  **Systemd**: Ensure systemd is enabled in `/etc/wsl.conf`:
    ```ini
    [boot]
    systemd=true
    ```

## WSL2 Resource Configuration (Critical)

Create or edit `%UserProfile%\.wslconfig` in Windows to prevent WSL2 from consuming all host RAM and to ensure it has enough for the stack.

```ini
[wsl2]
memory=12GB   # Adjust based on your total RAM. Leave 4GB for Windows.
processors=4  # Assign at least 4 cores.
swap=4GB
localhostForwarding=true
```
*Run `wsl --shutdown` in PowerShell after editing for changes to take effect.*

## Tools Setup

Install these tools in your WSL2 environment or Windows (if using PowerShell):

1.  **Kubectl**:
    *   `curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"`
    *   `chmod +x kubectl && sudo mv kubectl /usr/local/bin/`
2.  **Helm**:
    *   `curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash`
3.  **ArgoCD CLI**:
    *   `curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64`
    *   `sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd`

## Verify Installation

```bash
kubectl get nodes
kubectl get pods -A
```

You should see your node `Ready` and core pods (coredns, metrics-server, storage-provisioner) running.

## Next Steps

Proceed to the root of this repository and follow the installation instructions to deploy the stack using ArgoCD.
