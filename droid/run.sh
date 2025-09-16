#!/usr/bin/env bash

# NixOS Droid Container Runner
# Run this from /nix-modules directory

set -e

CONTAINER_NAME="nixos-droid"
IMAGE_NAME="nixos-droid"

echo "🚀 NixOS Droid Container Setup"
echo "================================"

# Check if we're in the right directory
if [ ! -f "droid/configuration.nix" ]; then
    echo "❌ Error: Run this script from /nix-modules directory"
    exit 1
fi

# Check if podman is installed
if ! command -v podman &> /dev/null; then
    echo "📦 Podman not found. Installing..."
    if command -v apt &> /dev/null; then
        sudo apt update && sudo apt install -y podman
    else
        echo "❌ Please install podman manually"
        exit 1
    fi
fi

# Build the container
echo ""
echo "🔨 Building container image..."
echo "This may take a few minutes on first run..."
podman build -f droid/Dockerfile -t $IMAGE_NAME .

# Check if container already exists
if podman container exists $CONTAINER_NAME; then
    echo ""
    echo "♻️  Removing existing container..."
    podman rm -f $CONTAINER_NAME
fi

# Run the container
echo ""
echo "🐋 Starting container..."
podman run -d \
    --name $CONTAINER_NAME \
    --hostname droid \
    --network host \
    --volume $HOME:/host-home:Z \
    --volume $(pwd):/nix-modules:ro \
    --env TERM=xterm-256color \
    $IMAGE_NAME \
    tail -f /dev/null

echo ""
echo "✅ Container started successfully!"
echo ""
echo "📝 Usage:"
echo "  Enter:    podman exec -it $CONTAINER_NAME zsh"
echo "  Stop:     podman stop $CONTAINER_NAME"
echo "  Restart:  podman start $CONTAINER_NAME"
echo "  Remove:   podman rm $CONTAINER_NAME"
echo "  Rebuild:  ./droid/run.sh"
echo ""
echo "📂 Volumes:"
echo "  Your home: /host-home"
echo "  This repo: /nix-modules (read-only)"
echo ""
echo "Entering container now..."
echo "================================"
echo ""

# Enter the container
podman exec -it $CONTAINER_NAME zsh