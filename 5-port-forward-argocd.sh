#!/bin/bash

echo "Port forwarding ArgoCD server to localhost:8080..."
echo "Access ArgoCD UI at: http://localhost:8080"
echo ""
echo "Default credentials:"
echo "  Username: admin"
PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo "  Password: $PASSWORD"
echo ""
echo "Press Ctrl+C to stop port forwarding"
echo ""

kubectl port-forward svc/argocd-server -n argocd 8080:443
