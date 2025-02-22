#!/bin/bash

# Script to install GitLab and update Argo CD to use GitLab.

# Set the VM's IP address
VM_IP=$(hostname -I | awk '{print $2}')

# Update and install dependencies
echo "Updating system and installing dependencies..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl openssh-server ca-certificates postfix

# Install GitLab
echo "Installing GitLab..."
curl -sS https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | sudo bash
sudo apt install -y gitlab-ce

# Configure GitLab
echo "Configuring GitLab..."
# Automatically set the external_url in gitlab.rb
sudo sed -i "s|external_url 'http://gitlab.example.com'|external_url 'http://$VM_IP'|g" /etc/gitlab/gitlab.rb
sudo gitlab-ctl reconfigure

# Save the initial root password
echo "Saving GitLab root password to gitlab-root-password.txt..."
sudo cat /etc/gitlab/initial_root_password | grep "Password:" > gitlab-root-password.txt

# Update Argo CD to use GitLab
echo "Updating Argo CD to use GitLab..."
cat <<EOF | kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: app1
  namespace: argocd
spec:
  project: default
  source:
    repoURL: http://$VM_IP/root/iouazzan.git  # Replace with your GitLab repository URL
    path: apps  # Path to the manifests in the repository
    targetRevision: main  # Git branch or revision
  destination:
    server: https://kubernetes.default.svc  # Target cluster (use this for the same cluster)
    namespace: dev  # Target namespace
  syncPolicy:
    automated:  # Optional: Enable automated syncing
      selfHeal: true  # Automatically correct drift
      prune: true  # Delete resources that are no longer in Git
EOF

echo "============================================"
echo "GitLab installation and Argo CD update complete!"
echo "Access GitLab at: http://$VM_IP"
echo "Access Argo CD at: https://localhost:8080"
echo "============================================"