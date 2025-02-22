#!/bin/bash

# Script to automate the setup of Docker, K3d, Argo CD, and Wil's application.
# After running this script, you can access Argo CD at http://localhost:8080.


# kubectl port-forward svc/wil-playground -n dev 8888:8888
# curl http://localhost:8888


# kubectl apply -f https://raw.githubusercontent.com/emmaOa/iouazzan/main/app1.yaml

# Update and install dependencies
echo "Updating system and installing dependencies..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl git

# Install Docker
echo "Installing Docker..."
sudo apt install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
sudo newgrp docker
