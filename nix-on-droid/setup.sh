#!/usr/bin/env bash

# Initial Nix-on-Droid Setup Script
# Run this after installing Nix-on-Droid from F-Droid

echo "📱 Setting up Nix-on-Droid for Pixel 9 Pro..."

# 1. First-time bootstrap with minimal config
echo "Step 1: Initial bootstrap..."
nix-on-droid switch --flake "github:0x64616e61/nix-modules?dir=nix-on-droid#default"

echo "✅ Setup complete!"
echo ""
echo "📝 Next steps:"
echo "1. Restart your terminal session"
echo "2. Test with: git --version"
echo "3. Connect to GPD: ssh mini (or gpd)"
echo ""
echo "To update config later:"
echo "  cd ~/nix-modules/nix-on-droid"
echo "  rebuild"