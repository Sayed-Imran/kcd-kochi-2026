#!/usr/bin/env bash
set -euo pipefail

istioctl install --set profile=default -y

kubectl rollout status deployment/istiod -n istio-system
