#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

kind create cluster --config "$SCRIPT_DIR/kind-config.yaml"

kubectl create ns prod
kubectl apply -f secret.yaml
kubectl apply -f secret.yaml -n prod

