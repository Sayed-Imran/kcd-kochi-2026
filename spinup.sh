#!/bin/bash

set -e

echo "=== Starting cluster spinup process ==="
echo ""

echo "Step 0: Creating kind cluster..."
./0-create-kind-cluster.sh
echo ""

echo "Step 1: Copying images..."
./1-cp-images.sh
echo ""

echo "Step 2: Installing KRO..."
./2-install-kro.sh
echo ""

echo "Step 3: Installing ArgoCD..."
./3-install-argocd.sh
echo ""

echo "=== Spinup complete! ==="
