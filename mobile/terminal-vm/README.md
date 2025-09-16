# Minimal NixOS Container for Terminal VM

The simplest way to get a NixOS environment on your Android Terminal VM.

## 🚀 One-Line Install

In Terminal VM, just run:

```bash
curl -L https://raw.githubusercontent.com/0x64616e61/nix-modules/production/mobile/terminal-vm/install.sh | bash
```

That's it! You'll have a working NixOS container with all essential dev tools.

## ✨ What You Get

- **NixOS container** with Podman (no root needed)
- **Essential tools**: git, neovim, tmux, zsh
- **Modern CLI**: ripgrep, fd, bat, eza, fzf
- **Your home mounted**: Access all your files at `/host-home`
- **Network access**: Full host networking

## 📝 Daily Usage

### Enter the container:
```bash
podman start -ai nixos-mobile
```

### Quick commands:
- `gs` - git status
- `ll` - list files with icons
- `gpd` - SSH to your GPD
- `mini` - SSH via Tailscale

### Update packages:
```bash
# Inside container
nix-env -u '*'
```

### Add more packages:
```bash
# Inside container
nix-env -iA nixpkgs.packagename
```

## 🔄 Staying Updated

### Update container config from GitHub:
```bash
# Pull latest install script and re-run
curl -L https://raw.githubusercontent.com/0x64616e61/nix-modules/production/mobile/terminal-vm/install.sh | bash
```

### Update just the config:
```bash
# Inside container
curl -L https://raw.githubusercontent.com/0x64616e61/nix-modules/production/mobile/terminal-vm/config.nix > /tmp/config.nix
# Review and apply as needed
```

## 🎯 Philosophy

This setup prioritizes:
1. **Simplicity** - One command to get started
2. **Speed** - Minimal container, fast startup
3. **Flexibility** - Easy to extend with more packages
4. **Updates** - Pull latest from GitHub anytime

## 📦 Extending

Need more tools? Just install them:

```bash
# Development
nix-env -iA nixpkgs.nodejs nixpkgs.python3 nixpkgs.gcc

# Networking
nix-env -iA nixpkgs.tailscale nixpkgs.syncthing

# Productivity
nix-env -iA nixpkgs.gh nixpkgs.jq nixpkgs.yq
```

## 🔧 Customization

Fork this repo and modify `config.nix` to:
- Add your preferred packages
- Set your git config
- Add shell aliases
- Configure editors

Then update the install script URL to point to your fork.

## 🐛 Troubleshooting

### Container won't start:
```bash
podman rm nixos-mobile
# Re-run install script
```

### Permission denied:
```bash
# Add :Z flag to volumes for SELinux
podman run --volume $HOME:/host-home:Z ...
```

### Network issues:
Terminal VM uses host networking, so check:
```bash
ip addr show
ping google.com
```

## 🚀 Why This Approach?

- **No flakes complexity** - Just Nix packages
- **No build time** - Pre-built container
- **GitHub-driven** - Config lives in your repo
- **Minimal** - Only what you need
- **Fast** - Seconds to update

Perfect for mobile development without the overhead!