#!/bin/bash

# Script to automate the setup of Docker, K3d, Argo CD, and Wil's application.
# After running this script, you can access Argo CD at http://localhost:8080.


# kubectl port-forward svc/wil-playground -n argocd 8888:8888
# curl http://localhost:8888


# kubectl apply -f https://raw.githubusercontent.com/emmaOa/iouazzan/main/apps/app1.yaml

# Update and install dependencies
echo "Updating system and installing dependencies..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl git

# Install Docker
echo "Installing Docker..."
sudo apt install docker.io 
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
newgrp docker

# Install K3d
echo "Installing K3d..."
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# Create a K3d cluster
echo "Creating K3d cluster..."
k3d cluster create mycluster

# Install kubectl (if not already installed)
echo "Installing kubectl..."
snap install kubectl --classic

# Install Argo CD
echo "Installing Argo CD..."
kubectl create namespace argocd
kubectl create namespace dev
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for Argo CD to be ready
echo "Waiting for Argo CD to be ready..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=300s

# Get the Argo CD password and save it to a file
echo "Saving Argo CD password to argocd-password.txt..."
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d > argocd-password.txt
echo "Argo CD password saved to argocd-password.txt."

# Set up port forwarding for Argo CD
echo "Setting up port forwarding for Argo CD..."
kubectl port-forward svc/argocd-server -n argocd 8080:443 &

# Display instructions
echo "============================================"
echo "Argo CD setup is complete!"
echo "Access the Argo CD UI at: https://localhost:8080"
echo "Username: admin"
echo "Password: $(cat argocd-password.txt)"
echo "============================================"

# Keep the script running to maintain port forwarding
echo "Press Ctrl+C to stop port forwarding and exit the script."
wait