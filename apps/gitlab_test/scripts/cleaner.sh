#!/bin/bash

# Script to clean up GitLab, K3d, GitLab Runner, and related resources.
# This will return the VM to a clean state.

# Delete the K3d cluster
echo "Deleting K3d cluster..."
k3d cluster delete mycluster

# Uninstall GitLab
echo "Uninstalling GitLab..."
sudo apt remove --purge gitlab-ce -y
sudo rm -rf /etc/gitlab
sudo rm -rf /var/opt/gitlab

# Uninstall GitLab Runner
echo "Uninstalling GitLab Runner..."
sudo apt remove --purge gitlab-runner -y
sudo rm -rf /etc/gitlab-runner

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
sudo snap remove kubectl

# Clean up Kubernetes configurations
echo "Cleaning up Kubernetes configurations..."
rm -rf ~/.kube

# Remove GitLab root password file
echo "Removing GitLab root password file..."
rm -f gitlab-root-password.txt

# Final cleanup
echo "Cleaning up unused packages..."
sudo apt autoremove -y
sudo apt clean

echo "============================================"
echo "Cleanup complete! Your VM is now clean."
echo "============================================"