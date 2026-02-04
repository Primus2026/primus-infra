#!/bin/bash
set -e

echo "=== AMD ROCm Setup for WSL2 ==="
echo "WARNING: Ensure you have installed the AMD Software: Adrenalin Edition™ 26.1.1 for WSL2 on Windows first!"
echo "Link: https://www.amd.com/en/resources/support-articles/release-notes/RN-RAD-WIN-26-1-1.html"
echo ""

# Detect Ubuntu version
UBUNTU_CODENAME=$(lsb_release -cs)
echo "Detected Ubuntu version: $UBUNTU_CODENAME"

if [ "$UBUNTU_CODENAME" != "jammy" ] && [ "$UBUNTU_CODENAME" != "noble" ]; then
    echo "Error: Only Ubuntu 22.04 (jammy) and 24.04 (noble) are strictly supported by the automated script."
    echo "Proceeding with 'jammy' repository as fallback..."
    UBUNTU_CODENAME="jammy"
fi

# Install amdgpu-install
echo "Installing amdgpu-install..."
sudo apt update
wget https://repo.radeon.com/amdgpu-install/7.2/ubuntu/$UBUNTU_CODENAME/amdgpu-install_7.2.70200-1_all.deb
sudo apt install -y ./amdgpu-install_7.2.70200-1_all.deb
rm amdgpu-install_7.2.70200-1_all.deb

# Run installation for WSL usecase
echo "Running amdgpu-install for WSL/ROCm..."
amdgpu-install -y --usecase=wsl,rocm --no-dkms

# Add user to render group
echo "Adding user to render/video groups..."
sudo usermod -aG render $USER
sudo usermod -aG video $USER

echo ""
echo "=== Installation Complete ==="
echo "1. Please RESTART WSL (wsl --shutdown in PowerShell)."
echo "2. Verify installation with 'rocminfo'."
echo "3. Only if you see Agent 2 (GPU), proceed to run docker compose."
