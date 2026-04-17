#!/bin/bash


# List of images to check and load
IMAGE_LIST=(
    "registry.k8s.io/kro/kro:v0.9.1"
    "ecr-public.aws.com/docker/library/redis:8.2.3-alpine"
    "ghcr.io/dexidp/dex:v2.45.1"
    "quay.io/argoproj/argocd:v3.3.7"
)

echo "Checking for kind cluster..."
CLUSTER_NAME=$(kind get clusters 2>/dev/null | head -n 1)

if [ -z "$CLUSTER_NAME" ]; then
    echo "Error: No kind cluster found. Please create a cluster first."
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