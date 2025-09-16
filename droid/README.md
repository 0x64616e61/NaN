# NixOS Droid Container

Minimal NixOS container configuration for mobile development, linking to packages from the main GPD configuration.

## 📱 What This Is

A containerized NixOS environment that:
- References package selections from your main config
- Runs in Podman on Terminal VM (Android)
- Provides consistent development environment with your GPD
- Requires minimal changes to your existing setup

## 🚀 Quick Start

On your phone in Terminal VM:

```bash
# Clone your nix-modules repo
git clone https://github.com/0x64616e61/nix-modules.git
cd nix-modules

# Run the container
./droid/run.sh
```

That's it! You'll be in a NixOS container with all your CLI tools.

## 📦 What's Included

Packages extracted from your existing configuration:
- **Core Dev**: git, neovim, tmux, gh
- **Modern CLI**: ripgrep, fd, bat, eza, zoxide, fzf, starship
- **Languages**: nodejs, python3, gcc
- **Network**: curl, wget, ssh, nmap
- **File Sync**: syncthing, rclone
- **System**: btop, htop, neofetch

All with your familiar aliases and configurations!

## 📝 Configuration

The setup consists of just 3 files:

### `configuration.nix`
- NixOS system configuration
- References packages from your main setup
- Container-optimized (no desktop, no hardware modules)

### `Dockerfile`
- Builds NixOS container from configuration
- Based on `nixos/nix:latest`

### `run.sh`
- Builds and runs the container
- Mounts your home directory at `/host-home`
- Mounts the repo at `/nix-modules` (read-only)

## 🔄 Updating

To update with latest from your main config:

```bash
# Pull latest changes
cd /nix-modules
git pull

# Rebuild container
./droid/run.sh
```

## 🎯 Design Philosophy

- **Minimal changes**: Your main config is untouched
- **No duplication**: References existing package lists
- **Container-friendly**: Only CLI tools, no GUI
- **Easy updates**: Pull from GitHub, rebuild

## 🛠️ Daily Usage

### Container Management
```bash
# Enter container
podman exec -it nixos-droid zsh

# Stop container
podman stop nixos-droid

# Restart container
podman start nixos-droid

# Remove and rebuild
podman rm nixos-droid
./droid/run.sh
```

### Inside Container
```bash
# Your aliases work
gs    # git status
ll    # eza with icons
btop  # system monitor

# SSH to GPD
gpd   # via hotspot
mini  # via Tailscale

# File access
cd /host-home  # Your phone's home
cd /nix-modules  # This repo
```

## 🔗 Relationship to Main Config

This container selectively uses:
- ✅ CLI packages from `modules/system/default.nix`
- ✅ Shell configuration style
- ✅ Git settings from `hydenix.hm.git`
- ❌ No desktop environment
- ❌ No hardware-specific modules
- ❌ No GUI applications

## 📱 Perfect For

- Mobile development on Terminal VM
- Quick edits and git commits
- SSH access to your GPD
- Consistent environment across devices