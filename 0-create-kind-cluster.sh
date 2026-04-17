#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

kind create cluster --config "$SCRIPT_DIR/kind-config.yaml"

kubectl apply -f secret.yaml