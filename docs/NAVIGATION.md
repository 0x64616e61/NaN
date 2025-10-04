# Documentation Navigation

Welcome to the nix-modules documentation! This guide helps you find the right documentation for your needs.

---

## 🚀 New Users - Start Here!

**Never used this configuration before?** Follow this path:

1. **[Installation Guide](./installation.md)** - Get up and running **(15 minutes)**
2. **[Quick Start Guide](#quick-start-below)** - Essential commands and first steps **(5 minutes)**
3. **[Configuration Basics](#configuration-basics)** - Customize your system **(20 minutes)**

---

## 📚 Documentation by Purpose

### I Want to...

#### **Install the System**
- 📖 [Installation Guide](./installation.md) - Fresh NixOS installation
- 📖 [Migration Guide](./migration.md) - Coming from existing NixOS setup
- 📖 [Hardware Setup](./hardware-setup.md) - GPD Pocket 3 specific configuration

#### **Configure My System**
- 📖 [Options Reference](./options-reference.md) - **All available options with examples**
- 📖 [Module Categories](#module-organization) - Browse by feature area
- 📖 [Configuration Examples](./examples/) - Copy-paste ready configs

#### **Fix Problems**
- 🔧 [Troubleshooting Checklist](./troubleshooting-checklist.md) - **Start here for issues**
- 🔧 [FAQ](./faq.md) - Common questions and answers
- 🔧 [Known Issues](./troubleshooting.md#known-issues) - Current limitations

#### **Understand the System**
- 🏗️ [Architecture Overview](./architecture.md) - How everything fits together
- 🏗️ [Module System](./module-system.md) - Understanding the structure
- 🏗️ [Features Overview](./FEATURES.md) - What this config provides

#### **Develop/Contribute**
- 💻 [CLAUDE.md](../CLAUDE.md) - **AI assistant integration guide**
- 💻 [Contributing Guide](./contributing.md) - How to add modules
- 💻 [Module Development](./module-development.md) - Creating custom modules

---

## ⚡ Quick Start (For Existing Users)

### Essential Commands

```bash
# Rebuild system (always use --impure for hardware detection)
cd /nix-modules
sudo nixos-rebuild switch --flake .#NaN --impure

# Quick commit + push + rebuild
update!

# Test without switching
rebuild-test

# Emergency rollback
panic    # or: A!, AA!, AAA!

# Get help
help-aliases    # Show all available commands
```

### Flake Name Reference

This repository uses **three flake names** that all point to the same configuration:

| Flake Name | Status | When to Use |
|------------|--------|-------------|
| `.#NaN` | ✅ **Primary** | Use this for all new commands |
| `.#hydenix` | ⚠️ Legacy | Kept for compatibility (deprecated) |
| `.#mini` | ⚠️ Legacy | Kept for compatibility (deprecated) |

**Recommendation:** Always use `.#NaN` going forward. Old names will be removed in v3.0.

---

## 📂 Module Organization

Modules are organized into logical categories:

### System Modules (`custom.system.*`)

Located in: `modules/system/`

- **hardware/** - Hardware-specific features
  - `auto-rotate.nix` - Screen rotation for convertible devices
  - `focal-spi/` - FTE3600 fingerprint reader support
  - `thermal-management.nix` - CPU temperature monitoring
  - `monitoring.nix` - Hardware health monitoring

- **power/** - Power management
  - `battery-optimization.nix` - TLP battery optimization
  - `lid-behavior.nix` - Lid close handling
  - `suspend-control.nix` - Suspend/resume configuration

- **security/** - Security features
  - `fingerprint.nix` - fprintd PAM integration
  - `secrets.nix` - KeePassXC secret management

- **packages/** - Custom packages and scripts
  - `superclaude.nix` - SuperClaude AI framework
  - `claude-code.nix` - Claude Code CLI integration
  - `mcp/` - MCP server configurations

### User Modules (`custom.hm.*`)

Located in: `modules/hm/`

- **applications/** - User applications
  - `firefox.nix` - Browser with Cascade theme
  - `ghostty.nix` - Main terminal emulator
  - `mpv.nix` - Video player configuration
  - `btop.nix` - System monitor

- **audio/** - Audio processing
  - `easyeffects.nix` - Audio effects and presets
  - `mpd.nix` - Music Player Daemon

- **desktop/** - Desktop environment
  - `hyprgrass-config.nix` - Touchscreen gestures
  - `hypridle.nix` - Idle management
  - `auto-rotate-service.nix` - Rotation service

- **hyprland/** - Hyprland configuration
  - Window rules, bindings, animations

- **waybar/** - Status bar configuration
  - Per-monitor waybar instances

---

## 🔍 Finding Configuration Options

### Method 1: Search Options Reference
```bash
# View all available options
cat /nix-modules/docs/options-reference.md

# Search for specific option
grep -i "fingerprint" /nix-modules/docs/options-reference.md
```

### Method 2: Browse Module Source
```bash
# List all system modules
ls /nix-modules/modules/system/

# Read module options
cat /nix-modules/modules/system/hardware/auto-rotate.nix
```

### Method 3: Use NixOS Option Query
```bash
# Query option details (if in active system)
nixos-option custom.system.hardware.autoRotate.enable
```

### Method 4: GitHub Search
Search the repository on GitHub:
- [Search "custom.system"](https://github.com/0x64616e61/nix-modules/search?q=custom.system)
- [Search "custom.hm"](https://github.com/0x64616e61/nix-modules/search?q=custom.hm)

---

## 📖 Configuration Basics

### Enabling a Module

All modules follow this pattern:

```nix
# In configuration.nix or modules/system/default.nix
custom.system.hardware.autoRotate = {
  enable = true;    # Must be set to activate module
  monitor = "DSI-1";  # Module-specific options
  scale = 1.5;
};
```

### Module Namespaces

Two main namespaces organize all options:

- **`custom.system.*`** - System-level configuration (needs sudo, affects all users)
- **`custom.hm.*`** - User-level configuration (Home Manager, per-user settings)

### Finding Option Defaults

Every module file shows defaults in the `options` section:

```nix
# In modules/system/hardware/auto-rotate.nix
options.custom.system.hardware.autoRotate = {
  monitor = mkOption {
    type = types.str;
    default = "eDP-1";    # ← Default value
    description = "Monitor to rotate";
  };
};
```

---

## 🔗 Related Documentation Files

### Quick Reference
- [README.md](../README.md) - Repository overview
- [USAGE.md](../USAGE.md) - Detailed usage guide
- [RULES.md](../RULES.md) - SuperClaude framework rules

### Detailed Guides
- [FEATURES.md](./FEATURES.md) - Complete feature list
- [Upgrading Guide](./upgrading.md) - Version migration
- [Hardware Todos](./hardware-todos.md) - Planned improvements
- [ACPI Errors](./ACPI_ERRORS_GPD_POCKET_3.md) - GPD-specific fixes

### Developer Resources
- [CLAUDE.md](../CLAUDE.md) - **Primary developer documentation**
- [Contributing](./contributing.md) - Module development guidelines
- [Community](./community.md) - Getting help and contributing

---

## 🆘 Getting Help

### Common Issues
1. **Build fails** → [Troubleshooting Checklist](./troubleshooting-checklist.md)
2. **Screen not rotating** → [Hardware Issues](./troubleshooting.md#rotation-not-working)
3. **Fingerprint not working** → [Security Issues](./troubleshooting.md#fingerprint-issues)
4. **Git push fails** → Check: `gh auth status`

### Where to Ask
- 🐛 **Bug Reports:** [GitHub Issues](https://github.com/0x64616e61/nix-modules/issues)
- 💬 **Questions:** [Community Resources](./community.md)
- 📧 **Security Issues:** [Private contact info]

---

## 📊 Documentation Quick Stats

- **Total Modules:** 61 (system: ~40, home-manager: ~21)
- **Configuration Options:** 219+ documented options
- **Documentation Pages:** 20+ markdown files
- **Example Configs:** Available in docs/examples/

---

## 🎯 Next Steps

**After reading this page:**

1. **New users:** Continue to [Installation Guide](./installation.md)
2. **Existing users:** Jump to [Options Reference](./options-reference.md)
3. **Developers:** Read [CLAUDE.md](../CLAUDE.md) for AI integration
4. **Troubleshooting:** Check [FAQ](./faq.md) or [Troubleshooting](./troubleshooting-checklist.md)

---

**Last Updated:** 2025-10-01
**Documentation Version:** 2.0
**Flake Name:** `.#NaN` (use this!)
