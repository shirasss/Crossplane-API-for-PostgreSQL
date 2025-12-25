#!/bin/bash
set -e

echo "======================================"
echo "Installing Crossplane Infrastructure"
echo "======================================"

echo ""
echo "[1/5] Installing Crossplane via Helm..."
helm repo add crossplane-stable https://charts.crossplane.io/stable
helm repo update
helm install crossplane crossplane-stable/crossplane \
  --namespace crossplane-system \
  --create-namespace \
  --version 1.16.0 \
  --set rbac.create=true \
  --set args='{--enable-composition-functions}' \
  --wait

echo ""
echo "[2/5] Installing provider-kubernetes..."
kubectl apply -f provider-kubernetes.yaml
echo "Waiting for provider to become healthy..."
kubectl wait --for=condition=Healthy provider/provider-kubernetes --timeout=5m

echo ""
echo "[3/5] Creating ProviderConfig..."
kubectl apply -f provider-config.yaml

echo ""
echo "[4/5] Applying RBAC..."
kubectl apply -f provider-rbac.yaml

echo ""
echo "[5/5] Installing function-go-templating..."
kubectl apply -f function-go-templating.yaml
echo "Waiting for function to become healthy..."
kubectl wait --for=condition=Healthy function/function-go-templating --timeout=5m

echo ""
echo "======================================"
echo "✅ Installation Complete!"
echo "======================================"
echo ""
echo "Next steps:"
echo "1. Deploy PostgreSQL: kubectl apply -f ../postgresql/"
echo "2. Apply CRDs: kubectl apply -f ../xappdatabase/xrd.yaml"
echo "3. Apply Composition: kubectl apply -f ../xappdatabase/composition.yaml"
echo "4. Create database: kubectl apply -f ../xappdatabase/examples/orders-db.yaml"