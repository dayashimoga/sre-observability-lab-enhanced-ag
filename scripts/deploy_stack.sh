
#!/bin/bash
# deploy_stack.sh - Master Automation Script
# Installs k3s, tools, and deploys the full stack.
set -e

# Logging
LOG_FILE="deploy.log"
exec > >(tee -a "$LOG_FILE") 2>&1
echo "📝 Logging output to $LOG_FILE"



SCRIPT_DIR=$(dirname "$0")

echo "🚀 Starting Master Deployment Script..."

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# 1. Infrastructure Checks & Installation
if ! command_exists kubectl || ! command_exists k3s; then
    echo "⚠️ k3s or kubectl not found. Invoking setup_k3s.sh..."
    
    # Check if setup_k3s.sh exists, if not, download or error out
    if [ -f "$SCRIPT_DIR/setup_k3s.sh" ]; then
        # Run setup script
        sudo bash "$SCRIPT_DIR/setup_k3s.sh"
        
        # Source the environment variables for this session
        export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
        echo "✅ Infrastructure installed. Proceeding..."
    else
        echo "❌ setup_k3s.sh not found in $SCRIPT_DIR!"
        exit 1
    fi
else
    echo "✅ Infrastructure (k3s/kubectl) appears to be installed."
    # Ensure KUBECONFIG is set if not already
    if [ -z "$KUBECONFIG" ]; then
        if [ -f /etc/rancher/k3s/k3s.yaml ]; then
            export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
            echo "ℹ️ Set KUBECONFIG to /etc/rancher/k3s/k3s.yaml"
        fi
    fi
fi

# 2. Wait for Cluster Readiness
echo "⏳ Verifying Cluster connectivity..."
until kubectl get nodes &> /dev/null; do
    echo "   Waiting for API server..."
    sleep 5
done
echo "✅ Cluster is Online."

# 3. Check/Install ArgoCD
echo "🔍 Checking ArgoCD..."
if ! kubectl get namespace argocd &> /dev/null; then
    echo "📦 Installing ArgoCD..."
    kubectl create namespace argocd
    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.10.1/manifests/install.yaml
    
    echo "⏳ Waiting for ArgoCD Server to be ready (this can take a few minutes)..."
    kubectl wait --for=condition=available deployment/argocd-server -n argocd --timeout=300s
else
    echo "✅ ArgoCD is already installed."
fi

# 4. Apply Root App
echo "🚀 Applying Root GitOps Application..."
# We explicitly use the recursive apply to ensure the repo is accepted
kubectl apply -f "$SCRIPT_DIR/../argocd-apps/root.yaml"

echo "--------------------------------------------------------"
echo "🎉 FULL STACK DEPLOYMENT COMPLETE!"
echo "--------------------------------------------------------"
echo "1. ArgoCD Password:"
echo "   $(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)"
echo ""
echo "2. Port Forward ArgoCD:"
echo "   kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo ""
echo "3. Monitor Deployment:"
echo "   kubectl get applications -n argocd"
echo "--------------------------------------------------------"
