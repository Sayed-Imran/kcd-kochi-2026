#!/bin/bash

export KRO_VERSION=$(curl -sL \
      https://api.github.com/repos/kubernetes-sigs/kro/releases/latest | \
      jq -r '.tag_name | ltrimstr("v")'
   )
export KRO_VARIANT=kro-core-install-manifests

echo $KRO_VERSION

kubectl create namespace kro-system
kubectl apply -f https://github.com/kubernetes-sigs/kro/releases/download/v$KRO_VERSION/$KRO_VARIANT.yaml

# Grant cluster-admin permissions to kro service account
echo "Creating ClusterRoleBinding for kro service account..."
kubectl create clusterrolebinding kro-cluster-admin \
  --clusterrole=cluster-admin \
  --serviceaccount=kro-system:kro \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Kro installation complete with cluster-admin permissions"