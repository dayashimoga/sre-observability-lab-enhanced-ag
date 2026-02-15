
#!/bin/bash
# cleanup_stack.sh - Teardown Resources
set -e

echo "⚠️  WARNING: This will delete the entire SRE Observability Lab stack."
read -p "Are you sure? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborting."
    exit 1
fi

echo "🔥 Deleting ArgoCD Applications..."
kubectl delete -f argocd-apps/root.yaml --ignore-not-found=true

echo "⏳ Waiting for cascading deletion..."
kubectl wait --for=delete application/observability-stack -n argocd --timeout=120s || echo "Timed out waiting for app deletion."

echo "🔥 Unsinstalling ArgoCD..."
kubectl delete namespace argocd --ignore-not-found=true

echo "🔥 Deleting Demo Namespaces..."
kubectl delete namespace observability --ignore-not-found=true
kubectl delete namespace demo --ignore-not-found=true

echo "🧹 Cleaning up PVCs (Storage)..."
kubectl delete pvc --all -A --ignore-not-found=true

echo "🎉 Cleanup Complete. Cluster is reset."
echo "To uninstall k3s completely from WSL, run: /usr/local/bin/k3s-uninstall.sh"
