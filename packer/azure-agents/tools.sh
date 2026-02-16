#!/usr/bin/env bash
set -e

export DEBIAN_FRONTEND=noninteractive

sudo echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
sudo echo 'APT::Acquire::Retries "3";' > /etc/apt/apt.conf.d/80-retries
sudo echo "APT::Get::Assume-Yes \"true\";" > /etc/apt/apt.conf.d/90assumeyes

sudo add-apt-repository main
sudo add-apt-repository restricted
sudo add-apt-repository universe
sudo add-apt-repository multiverse
sudo add-apt-repository ppa:git-core/ppa
sudo add-apt-repository ppa:deadsnakes/ppa

sudo apt-get clean && apt-get update && apt-get upgrade
sudo apt-get install -y --no-install-recommends \
  build-essential \
  ca-certificates \
  curl \
  gnupg \
  jq \
  libasound2 \
  libgbm-dev \
  libgconf-2-4 \
  libgtk2.0-0 \
  libgtk-3-0 \
  libnotify-dev \
  libnss3 \
  libxss1 \
  libxtst6 \
  lsb-release \
  software-properties-common \
  unzip \
  xauth \
  xvfb \
  zip

# Git
sudo apt-get install -y --no-install-recommends \
  git \
  git-lfs \
  git-ftp

# Python (Ubuntu 22 uses 3.10 by default)
sudo apt-get install -y --no-install-recommends \
  python3 \
  python3-distutils \
  python3-pip

## Install Chromium for test images
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
sudo apt-get update
sudo apt-get install -y google-chrome-stable

# Docker Engine
sudo apt-get install -y docker.io
sudo usermod -aG docker $USER
newgrp docker
sudo systemctl enable docker.service
sudo systemctl enable containerd.service

# Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Powershell
sudo snap install powershell --classic

# Terraform
curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get install -y terraform=1.13.3-1

# Terragrunt 0.55.1
sudo curl -s -L "https://github.com/gruntwork-io/terragrunt/releases/download/v0.55.1/terragrunt_linux_amd64" -o /usr/bin/terragrunt && chmod 777 /usr/bin/terragrunt

# Checkov
python3 -m pip install --force-reinstall packaging==21
python3 -m pip install -U checkov==3.2.405

# TFLint
curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash

# NVM
sudo mkdir /usr/local/nvm && chmod -R 777 /usr/local/nvm
sudo curl -o- https://raw.githubusercontent.com/creationix/nvm/master/install.sh | NVM_DIR=/usr/local/nvm bash

export NVM_DIR="/usr/local/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Install Node versions
nvm install 24
nvm install 22
nvm install 20

# Set default Node
nvm alias default 22
nvm use default

# Create symlinks to make Node.js 22 available globally without any pipeline setup
# Lines 105-116 are Co-pilot code used for testing purposes
# DEFAULT_NODE_VERSION=$(find /usr/local/nvm/versions/node -name "v22.*" -type d | head -1)
# if [ -n "$DEFAULT_NODE_VERSION" ] && [ -d "$DEFAULT_NODE_VERSION/bin" ]; then
#   # Create symlinks in /usr/local/bin (already in PATH)
#   sudo ln -sf "$DEFAULT_NODE_VERSION/bin/node" /usr/local/bin/node
#   sudo ln -sf "$DEFAULT_NODE_VERSION/bin/npm" /usr/local/bin/npm
#   sudo ln -sf "$DEFAULT_NODE_VERSION/bin/npx" /usr/local/bin/npx
  
#   echo "✅ Created Node.js 22 symlinks in /usr/local/bin/"
#   echo "✅ Node.js now available globally without pipeline setup"
# else
#   echo "❌ Node.js 22 not found, skipping symlink creation"
# fi

# Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | bash
sudo apt-get update
sudo apt-get install -y apt-transport-https

# Deprovision for image capture
/usr/sbin/waagent -force -deprovision+user && export HISTSIZE=0 && sync
