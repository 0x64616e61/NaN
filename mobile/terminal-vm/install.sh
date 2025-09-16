#!/usr/bin/env bash

# One-command NixOS container setup for Terminal VM
# Just curl and run!

set -e

echo "🚀 Quick NixOS Container Setup for Terminal VM"

# Check if running in Terminal VM
if [ ! -f /etc/debian_version ]; then
    echo "⚠️  This script is designed for Terminal VM (Debian-based)"
    exit 1
fi

# Install Podman if needed
if ! command -v podman &> /dev/null; then
    echo "📦 Installing Podman..."
    sudo apt update && sudo apt install -y podman
fi

# Create temp directory
TEMP_DIR=$(mktemp -d)
cd $TEMP_DIR

echo "📥 Downloading NixOS container configuration..."

# Create a minimal Dockerfile
cat > Dockerfile << 'EOF'
FROM nixos/nix:latest

# Enable flakes
RUN mkdir -p /etc/nix && \
    echo "experimental-features = nix-command flakes" >> /etc/nix/nix.conf

# Install essential packages directly
RUN nix-env -iA \
    nixpkgs.git \
    nixpkgs.neovim \
    nixpkgs.tmux \
    nixpkgs.zsh \
    nixpkgs.starship \
    nixpkgs.ripgrep \
    nixpkgs.fd \
    nixpkgs.bat \
    nixpkgs.eza \
    nixpkgs.fzf \
    nixpkgs.curl \
    nixpkgs.wget

# Configure shell
RUN echo 'eval "$(starship init zsh)"' >> /root/.zshrc

WORKDIR /root
CMD ["/usr/bin/env", "zsh"]
EOF

echo "🔨 Building container..."
podman build -t nixos-mobile .

echo "🐋 Creating container..."
podman create \
    --name nixos-mobile \
    --hostname mobile \
    --network host \
    --volume $HOME:/host-home:Z \
    -it \
    nixos-mobile

echo "✅ Container ready!"
echo ""
echo "📝 Usage:"
echo "  Start:  podman start -ai nixos-mobile"
echo "  Enter:  podman exec -it nixos-mobile zsh"
echo "  Stop:   podman stop nixos-mobile"
echo ""
echo "📂 Your home is mounted at: /host-home"
echo ""
echo "🔄 To update packages later:"
echo "  Inside container: nix-env -u '*'"
echo ""
echo "Starting container now..."
podman start -ai nixos-mobile