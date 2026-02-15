
#!/bin/bash
# setup_k3s.sh - Install k3s and tools
set -e

echo "🚀 Setting up k3s environment..."

# 1. Install k3s (without Traefik)
if [ ! -x "$(command -v k3s)" ]; then
    echo "📦 Installing k3s..."
    curl -sfL https://get.k3s.io | sh -s - --disable traefik --write-kubeconfig-mode 644
else
    echo "✅ k3s is already installed."
fi

# 2. Config Kubeconfig
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
echo "export KUBECONFIG=/etc/rancher/k3s/k3s.yaml" >> ~/.bashrc

# 3. Install Helm
if [ ! -x "$(command -v helm)" ]; then
    echo "📦 Installing Helm..."
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
else
    echo "✅ Helm is already installed."
fi

# 4. Install ArgoCD CLI
if [ ! -x "$(command -v argocd)" ]; then
    echo "📦 Installing ArgoCD CLI..."
    curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
    sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
    rm argocd-linux-amd64
else
    echo "✅ ArgoCD CLI is already installed."
fi

# 5. Wait for Node Ready
echo "⏳ Waiting for k3s node to be ready..."
k3s kubectl wait --for=condition=Ready node --all --timeout=60s

echo "--------------------------------------------------------"
echo "🎉 Setup Complete!"
echo "Run 'source ~/.bashrc' to load environment variables."
echo "You can now verify installation with: kubectl get nodes"
echo "--------------------------------------------------------"
