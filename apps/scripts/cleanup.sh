#!/bin/bash

# Script to clean up Docker, K3d, Argo CD, and related resources.
# This will return the VM to a clean state.

# Delete the K3d cluster
echo "Deleting K3d cluster..."
k3d cluster delete mycluster

# Uninstall Argo CD
echo "Uninstalling Argo CD..."
kubectl delete -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl delete namespace argocd

# Remove Docker
echo "Removing Docker..."
sudo apt remove --purge docker docker-engine docker.io containerd runc -y
sudo rm -rf /var/lib/docker
sudo rm -rf /etc/docker
sudo snap remove docker

# Remove K3d
echo "Removing K3d..."
sudo rm -f /usr/local/bin/k3d

# Remove kubectl
echo "Removing kubectl..."
sudo apt remove --purge kubectl -y

# Clean up Kubernetes configurations
echo "Cleaning up Kubernetes configurations..."
rm -rf ~/.kube

# Remove the Argo CD password file
echo "Removing Argo CD password file..."
rm -f argocd-password.txt

# Final cleanup
echo "Cleaning up unused packages..."
sudo apt autoremove -y
sudo apt clean

echo "============================================"
echo "Cleanup complete! Your VM is now clean."
echo "============================================"