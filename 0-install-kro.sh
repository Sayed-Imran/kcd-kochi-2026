#!/bin/bash

export KRO_VERSION=$(curl -sL \
      https://api.github.com/repos/kubernetes-sigs/kro/releases/latest | \
      jq -r '.tag_name | ltrimstr("v")'
   )
export KRO_VARIANT=kro-core-install-manifests

echo $KRO_VERSION

kubectl create namespace kro-system
kubectl apply -f https://github.com/kubernetes-sigs/kro/releases/download/v$KRO_VERSION/$KRO_VARIANT.yaml