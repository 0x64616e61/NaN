# Mobile Development Configurations

Optimized NixOS configurations for mobile development on Pixel 9 Pro with GrapheneOS.

## 📱 Choose Your Platform

### [Terminal VM](./terminal-vm/) - **RECOMMENDED**
Google's Debian-based VM for Android with full Linux environment.
- ✅ Best performance (real VM, not proot)
- ✅ Full systemd support
- ✅ Docker/Podman capable
- ✅ Works perfectly on GrapheneOS

**Quick Install:**
```bash
curl -L https://raw.githubusercontent.com/0x64616e61/nix-modules/production/mobile/terminal-vm/install.sh | bash
```

### [Nix-on-Droid](./nix-on-droid/) - Alternative
Pure Nix environment running in proot on Android.
- ⚠️ Slower performance (proot overhead)
- ⚠️ Bootstrap issues on GrapheneOS
- ✅ Works without Terminal VM
- ✅ Declarative configuration

**Quick Install:**
```bash
nix-on-droid switch --flake "github:0x64616e61/nix-modules?dir=mobile/nix-on-droid#default"
```

## 🎯 Recommendation

**Use Terminal VM** for the best experience. It provides a real Linux environment with better performance and compatibility.

## 📂 Repository Structure

```
mobile/
├── terminal-vm/        # Terminal VM configurations
│   ├── install.sh     # One-command setup
│   ├── config.nix     # NixOS container config
│   └── README.md      # Terminal VM documentation
└── nix-on-droid/      # Nix-on-Droid configuration
    ├── flake.nix      # Flake definition
    ├── configuration.nix # System configuration
    └── README.md      # Nix-on-Droid documentation
```

## 🚀 Features

Both configurations provide:
- Modern CLI tools (ripgrep, fd, bat, eza, zoxide)
- Development environment (git, neovim, tmux)
- SSH pre-configured for GPD access
- Syncthing for file sync
- GitHub CLI for mobile commits
- Catppuccin theme matching GPD setup

## 📝 Syncing with GPD

All configurations are designed to complement your GPD Pocket 3 setup:
- Same shell aliases and shortcuts
- Matching tool configurations
- Pre-configured SSH access
- Syncthing for bidirectional file sync