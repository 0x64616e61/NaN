# NixOS Hydenix Configuration

A modern, modular NixOS configuration using Hydenix, Hyprland, and flakes with automatic hardware detection and GitHub synchronization.

## 📖 Documentation

**New here? Start with the [Documentation Navigation Hub](docs/NAVIGATION.md)**

Quick Links:
- 🆕 [Installation Guide](docs/installation.md) - Get up and running
- 🔧 [Troubleshooting Checklist](docs/troubleshooting-checklist.md) - Fix issues fast
- 📚 [Options Reference](docs/options.md) - Browse all configuration options
- 🏗️ [Architecture Overview](docs/architecture.md) - Understand the system
- 🔄 [Migration Guide](docs/migration.md) - Migrate from existing NixOS

## 🚀 Features

- **Hydenix Desktop Environment** - Pre-configured Hyprland-based desktop with modern aesthetics
- **Automatic Hardware Detection** - Smart hardware configuration management that survives repository syncs
- **Auto-commit to GitHub** - Automatically commits and pushes configuration changes on rebuild
- **Flake-based Configuration** - Reproducible, version-pinned system configuration
- **Home Manager Integration** - Declarative user environment management
- **Modular Structure** - Clean separation of system and user configurations (61 modules)
- **Secure Command System** - No hardcoded passwords, polkit-based privilege escalation
- **Input Validation** - Catch configuration errors before build time

## 📋 Quick Start

- NixOS 24.11 or later
- Git installed and configured
- GitHub account (for auto-sync features)
- Basic understanding of NixOS and flakes

## 🛠️ Installation

### 1. Clone the Repository

```bash
sudo git clone https://github.com/0x64616e61/nix-modules.git /nix-modules
cd /nix-modules
```

### 2. Hardware Configuration

The system automatically detects and uses your local hardware configuration. No manual copying required!

⚠️ **Important**: Always rebuild with the `--impure` flag to ensure hardware detection works:

```bash
sudo nixos-rebuild switch --flake .#hydenix --impure
```

### 3. Initial Setup

1. **Update User Configuration**
   - Edit `configuration.nix`
   - Change username from "a" to your desired username (lines 75 and 87)
   - Update initial password (line 89)
   - Set your hostname (line 103)
   - Configure timezone and locale (lines 104-105)

2. **Configure GitHub Authentication** (for auto-sync)
   ```bash
   gh auth login
   ```

3. **Build and Switch**
   ```bash
   sudo nixos-rebuild switch --flake .#hydenix --impure
   ```

## 📁 Project Structure

```
/nix-modules/
├── flake.nix                 # Flake configuration entrypoint
├── flake.lock               # Version lock file
├── configuration.nix        # Main system configuration
├── hardware-config.nix      # Hardware detection wrapper
├── hardware-configuration.nix  # Placeholder (auto-replaced)
├── modules/
│   ├── system/             # System-level modules
│   │   └── auto-commit.nix # GitHub auto-sync module
│   └── hm/                 # Home Manager modules
└── docs/                   # Documentation
```

## 🔧 Configuration

### System Configuration

Main configuration file: `configuration.nix`

Key settings to customize:
- **Username**: Update in both `home-manager.users` and `users.users`
- **Hostname**: Set in `hydenix.hostname`
- **Timezone**: Set in `hydenix.timezone` (e.g., "America/New_York")
- **Locale**: Set in `hydenix.locale` (e.g., "en_US.UTF-8")
- **Hardware modules**: Uncomment relevant lines for GPU, CPU, laptop features

### Home Manager Configuration

User-specific configurations in `modules/hm/`

Manages:
- Desktop environment settings
- Application configurations
- User packages
- Dotfiles

## 🎯 Key Features Explained

### Automatic Hardware Detection

The configuration includes a smart hardware detection system that:
- Uses `/etc/nixos/hardware-configuration.nix` when available
- Falls back to a placeholder for repository storage
- Survives git pulls without breaking your system
- Requires `--impure` flag for nixos-rebuild

### Auto-commit to GitHub

On every rebuild, the system:
1. Checks for uncommitted changes
2. Automatically commits with timestamp
3. Pushes to GitHub using `gh` CLI
4. Handles authentication gracefully

To disable auto-commit, remove this line from `configuration.nix`:
```nix
./modules/system/auto-commit.nix
```

### Hydenix Integration

Hydenix provides:
- Pre-configured Hyprland window manager
- Modern UI/UX with animations
- Integrated application launcher
- Workspace management
- Screen recording/screenshot tools

## 🔄 Daily Usage

### Rebuilding the System

Always use the impure flag for hardware detection:
```bash
cd /nix-modules
sudo nixos-rebuild switch --flake .#hydenix --impure
```

### Updating from GitHub

```bash
cd /nix-modules
sudo git pull origin main
sudo nixos-rebuild switch --flake .#hydenix --impure
```

### Manual Commit and Push

If auto-commit is disabled or fails:
```bash
cd /nix-modules
sudo git add -A
sudo git commit -m "Your commit message"
sudo git push origin main
```

## 🐛 Troubleshooting

### Hardware Configuration Issues

If system won't boot after pulling from GitHub:
1. Boot from previous generation (select in GRUB)
2. Copy your hardware config:
   ```bash
   sudo cp /etc/nixos/hardware-configuration.nix /nix-modules/
   ```
3. Rebuild with `--impure` flag

### GitHub Authentication

If auto-push fails:
```bash
gh auth login
# Follow the prompts to authenticate
```

### Dirty Git Tree Warnings

This is normal when you have uncommitted changes. The auto-commit module will handle this, or commit manually.

### Permission Errors

Most operations require sudo as `/nix-modules` is system-wide:
```bash
sudo git add -A
sudo nixos-rebuild switch --flake .#hydenix --impure
```

## 🚦 Best Practices

1. **Always use `--impure` flag** when rebuilding
2. **Test changes locally** before pushing to GitHub
3. **Keep secrets out of configuration** - they'll be world-readable in Nix store
4. **Regular commits** - Let auto-commit handle routine changes
5. **Document custom modules** - Add comments for future reference
6. **Version control discipline** - Review changes before rebuilding

## 📚 Additional Resources

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Home Manager Documentation](https://nix-community.github.io/home-manager/)
- [Hyprland Wiki](https://wiki.hyprland.org/)
- [Nix Flakes Guide](https://nixos.wiki/wiki/Flakes)
- [Hydenix Documentation](https://github.com/hydenix/hydenix)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly with `nixos-rebuild build`
5. Submit a pull request

## 📄 License

This configuration is provided as-is for personal use and learning purposes.

## ⚠️ Security Notes

- Change default passwords immediately after installation
- Don't commit secrets or sensitive data
- Review all configuration changes before applying
- Keep your system updated regularly

## 💡 Tips

- Use `nixos-rebuild build` to test without switching
- Check generation differences with `nixos-rebuild --rollback`
- View system logs with `journalctl -xe`
- List generations with `sudo nix-env --list-generations -p /nix/var/nix/profiles/system`

---

*Last updated: September 2025*
*Powered by NixOS, Hydenix, and Hyprland*
