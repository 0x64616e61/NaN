# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Personal NixOS configuration for GPD Pocket 3 device using Hydenix (Hyprland-based desktop environment template). Features hardware-specific optimizations, touchscreen gestures, fingerprint authentication, and modular system/home configuration.

## Key Commands

### System Configuration
```bash
# Build and switch to new configuration
sudo nixos-rebuild switch --flake .#hydenix

# Test configuration without permanent changes
sudo nixos-rebuild test --flake .#hydenix

# Build configuration without switching
sudo nixos-rebuild build --flake .#hydenix

# Check flake outputs and metadata
nix flake show
nix flake metadata
nix flake check

# Update flake inputs
nix flake update              # Update all inputs
nix flake update hydenix      # Update specific input

# View system generation differences
nixos-rebuild build --flake .#hydenix && nvd diff /run/current-system result
```

### Debugging and Development
```bash
# Monitor touch/gesture events
sudo libinput debug-events --device /dev/input/event18

# Check Hyprland plugin status
hyprctl plugins list

# Reload Hyprland configuration
hyprctl reload

# Manual waybar start (if needed)
waybar &

# Check journal for errors
journalctl -xe --user
journalctl -b -p err
```

## Architecture

### Core Components
The configuration leverages three interconnected systems:
1. **NixOS System** - Base OS configuration and hardware support
2. **Hydenix Framework** - Hyprland desktop environment with integrated tooling
3. **Home Manager** - User-specific configurations and dotfiles

### Module Hierarchy
```
hydenix.*                 # Core framework (Hyprland, waybar, themes)
├── custom.system.*       # System-level customizations
│   ├── hardware.*        # GPD Pocket 3 specific features
│   ├── power.*          # Lid behavior, suspend settings
│   ├── security.*       # Fingerprint, secrets management
│   └── packages.*       # System-wide packages
└── custom.hm.*          # User-level customizations
    ├── desktop.*        # Gestures, rotation, idle management
    ├── applications.*   # Firefox, music players, MPV
    └── audio.*          # EasyEffects configurations
```

### Current Configuration
- **User**: `dm` (groups: `wheel`, `networkmanager`, `video`, `input`)
- **Host**: `mini`
- **Shell**: `zsh`
- **Hardware**: GPD Pocket 3 with nixos-hardware module

## Hardware-Specific Features

### GPD Pocket 3 Support
- **Display**: DSI-1 with auto-rotation (modules/system/hardware/auto-rotate.nix:1)
- **Touchscreen**: GXTP7380:00 27C6:0113 via i2c
- **Fingerprint**: FTE3600 with custom kernel module (modules/system/hardware/focal-spi/:1)
- **Gestures**: Hyprgrass plugin for touchscreen (modules/system/hyprgrass.nix:1)
- **Power**: Custom lid behavior and suspend control (modules/system/power/:1)

### Working Features
- 3-finger horizontal swipe for workspace switching
- Fingerprint authentication (SDDM, sudo, swaylock)
- Screen auto-rotation based on device orientation
- Audio processing with EasyEffects and Meze_109_Pro preset
- KeePassXC auto-start for password management

## Development Workflow

### Configuration Changes
```bash
# 1. Edit relevant module file
# 2. Test changes without making permanent
sudo nixos-rebuild test --flake .#hydenix

# 3. If successful, apply permanently
sudo nixos-rebuild switch --flake .#hydenix

# 4. If issues occur, rollback
sudo nixos-rebuild switch --rollback
```

### Adding New Modules
1. Create `.nix` file in `modules/system/` or `modules/hm/`
2. Define options under `custom.system.*` or `custom.hm.*` namespace
3. Import in parent `default.nix`
4. Enable via options in configuration

### Package Management
- System packages: Add to `environment.systemPackages` in configuration.nix
- User packages: Add to `home.packages` in modules/hm/
- Custom packages: Create derivation in modules/system/packages/ (see superclaude.nix example)

## Current Issues

### Known Problems
- **Hyprgrass**: Only 3-finger swipes working; 2/4-finger gestures not responding
- **Fusuma**: Disabled due to Ruby gem installation failures in Nix
- **Home Manager**: Service may fail during rebuild (config still applies)

### Workarounds in Place
- **Waybar**: Fix module ensures startup script runs correctly (modules/hm/desktop/waybar-fix.nix:1)
- **Hypridle**: Custom config prevents music interruption (modules/hm/desktop/hypridle.nix:1)
- **Lid**: Set to ignore close events to prevent unwanted suspend

## Quick Reference

### Critical Files
- `configuration.nix` - Main system configuration and user setup
- `flake.nix` - Input management and system definition
- `modules/system/default.nix` - System module toggles
- `modules/hm/default.nix` - User environment options
- `SYSTEM_STATE.md` - Detailed status and known issues