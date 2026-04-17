#!/bin/bash


# List of images to check and load
IMAGE_LIST=(
    "registry.k8s.io/kro/kro:v0.9.1"
    "ecr-public.aws.com/docker/library/redis:8.2.3-alpine"
    "ghcr.io/dexidp/dex:v2.45.1"
    "quay.io/argoproj/argocd:v3.3.7"
    "registry.k8s.io/metrics-server/metrics-server:v0.8.1"
    "asia-south1-docker.pkg.dev/cncf-kcd/kcd-kochi-2026/backend:2026-04-15-2"
    "asia-south1-docker.pkg.dev/cncf-kcd/kcd-kochi-2026/prod/backend:2026-04-15-3"

)

echo "Checking for kind cluster..."
CLUSTER_NAME=$(kind get clusters 2>/dev/null | head -n 1)

if [ -z "$CLUSTER_NAME" ]; then
    echo "Error: No kind cluster found. Please create a c/luster first."
    exit 1
fi

echo "Found kind cluster: $CLUSTER_NAME"
echo ""

# Loop through each image in the list
for IMAGE in "${IMAGE_LIST[@]}"; do
    echo "Checking if image $IMAGE exists locally..."
    
    # Check if the image exists in local docker images
    if docker images --format "{{.Repository}}:{{.Tag}}" | grep -q "^${IMAGE}$"; then
        echo "✓ Image found locally: $IMAGE"
    else
        echo "✗ Image not found locally: $IMAGE"
        echo "Pulling image from registry..."
        
        if docker pull "$IMAGE"; then
            echo "✓ Successfully pulled $IMAGE"
        else
            echo "✗ Failed to pull $IMAGE"
            exit 1
        fi
    fi
    
    echo "Loading image into kind cluster '$CLUSTER_NAME'..."
    if kind load docker-image "$IMAGE" --name "$CLUSTER_NAME"; then
        echo "✓ Successfully loaded $IMAGE into cluster"
    else
        echo "✗ Failed to load $IMAGE into cluster"
        exit 1
    fi
    echo ""
done

echo "Image loading process completed!"

echo "Installing metrics server..."

# Install metrics-server with modifications for kind cluster
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

echo "Waiting for metrics-server deployment to be created..."
sleep 5

# Patch metrics-server to work with kind cluster (disable TLS verification)
kubectl patch deployment metrics-server -n kube-system --type='json' -p='[
  {
    "op": "add",
    "path": "/spec/template/spec/containers/0/args/-",
    "value": "--kubelet-insecure-tls"
  }
]'

echo "Waiting for metrics-server to be ready..."
kubectl wait --for=condition=available --timeout=120s deployment/metrics-server -n kube-system

echo "Metrics server installed successfully!"
echo ""