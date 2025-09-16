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

**100+ CLI tools** extracted from your main configuration:

### Development Environment
- **Version Control**: git, gh, lazygit
- **Editors**: neovim (fully configured), tmux
- **Languages**: Node.js, Python3, Go, Rust, GCC
- **Package Managers**: npm, yarn, pnpm, pip, cargo
- **Build Tools**: cmake, make, autoconf, automake
- **Debuggers**: gdb, strace, ltrace, valgrind, delve

### Modern CLI Tools
- **Search**: ripgrep, fd, ack, silver-searcher
- **File Viewing**: bat, eza, tree, duf
- **Navigation**: zoxide, fzf, starship prompt
- **System Monitoring**: btop, htop, iotop, iftop, nethogs

### DevOps & Infrastructure
- **Containers**: podman, buildah, docker-compose, lazydocker
- **Orchestration**: kubectl, k9s, terraform, ansible
- **Databases**: pgcli, mycli, redis

### Network & Security
- **Network Tools**: nmap, netcat, mtr, iperf3, dig, whois
- **VPN**: openvpn, wireguard-tools
- **Security**: gnupg, age, pass, sops

### File Management
- **Sync**: syncthing, rclone, rsync
- **Archives**: zip, unzip, p7zip, tar
- **Disk Tools**: gptfdisk, parted, disko, zfs, zfstools

### Media & Data
- **Media CLI**: youtube-tui, yt-dlp, ffmpeg, imagemagick
- **Data Processing**: jq, yq, xsv, pandoc

### Language-Specific Tools
- **Python**: ipython, black, pylint, pytest, virtualenv
- **Node**: typescript, prettier, eslint, nodemon
- **Rust**: rust-analyzer, cargo-edit, cargo-watch
- **Go**: gopls, gotools, go-tools

All with your familiar aliases and enhanced configurations!

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