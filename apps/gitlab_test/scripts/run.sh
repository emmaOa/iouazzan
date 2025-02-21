#!/bin/bash

# Script to automate the setup of GitLab, K3d, and GitLab Runner.
# After running this script, you can access GitLab at http://<your-vm-ip>.

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
sudo gitlab-ctl reconfigure

# Get the GitLab root password
echo "Saving GitLab root password to gitlab-root-password.txt..."
sudo cat /etc/gitlab/initial_root_password | grep "Password:" > gitlab-root-password.txt
echo "GitLab root password saved to gitlab-root-password.txt."

# Install K3d
echo "Installing K3d..."
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# Create a K3d cluster
echo "Creating K3d cluster..."
k3d cluster create mycluster

# Install kubectl
echo "Installing kubectl..."
sudo snap install kubectl --classic

# Install GitLab Runner
echo "Installing GitLab Runner..."
curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh | sudo bash
sudo apt install -y gitlab-runner

# Register GitLab Runner
echo "Registering GitLab Runner..."
sudo gitlab-runner register \
  --non-interactive \
  --url "http://$(hostname -I | awk '{print $1}')/" \
  --registration-token "$(sudo cat /etc/gitlab/initial_root_password | grep "Password:" | awk '{print $2}')" \
  --executor "shell" \
  --description "k3d-runner" \
  --tag-list "k3d" \
  --run-untagged

# Display instructions
echo "============================================"
echo "GitLab setup is complete!"
echo "Access GitLab at: http://$(hostname -I | awk '{print $1}')"
echo "Username: root"
echo "Password: $(cat gitlab-root-password.txt)"
echo "============================================"

# Keep the script running to maintain GitLab services
echo "Press Ctrl+C to stop the script."
wait