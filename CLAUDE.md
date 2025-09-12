# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Personal NixOS configuration for GPD Pocket 3 device using Hydenix (Hyprland-based desktop environment). Features hardware-specific optimizations, touchscreen gestures, fingerprint authentication, and modular system/home configuration.

## Critical Context

- **Repository Location**: `/nix-modules/` (system-wide, requires sudo for modifications)
- **Flake System**: `hydenix` - the only nixosConfiguration defined in flake.nix
- **Module System**: Two-tier option system with `hydenix.*` (core) and `custom.*` (extensions)
- **Sudo Password**: `7` (for system operations)

## Key Commands

### Quick System Management
```bash
# Quick update: commit, push, and rebuild in one command (uses password '7')
update!

# Create work summary commit (last 12 hours of work)
worksummary

# PANIC MODE - discard all local changes and reset to GitHub
panic
# Alternative: A!, AA!, AAA!, etc. (up to 20 A's)

# Standard rebuild (always use --impure for hardware detection)
sudo nixos-rebuild switch --flake .#hydenix --impure

# Test configuration without switching
sudo nixos-rebuild test --flake .#hydenix --impure

# Build only (no activation)
sudo nixos-rebuild build --flake .#hydenix --impure

# Rollback to previous generation
sudo nixos-rebuild switch --rollback
```

### Flake Management
```bash
# Update all flake inputs
nix flake update

# Update specific input
nix flake update hydenix

# Check flake metadata and outputs
nix flake show
nix flake metadata
nix flake check

# View system generation differences
nixos-rebuild build --flake .#hydenix --impure && nvd diff /run/current-system result
```

### Debugging Commands
```bash
# Monitor touchscreen/gesture events (GPD Pocket 3 touchscreen)
sudo libinput debug-events --device /dev/input/event18

# Hyprland diagnostics
hyprctl plugins list        # Check loaded plugins (should show hyprgrass)
hyprctl reload             # Reload configuration
hyprctl monitors           # Check monitor setup (should show DSI-1)

# Service and error checking
journalctl -xe --user      # User service logs
journalctl -b -p err       # Boot errors
systemctl --user status    # User services status

# Manual service starts (if needed)
waybar &                   # Start waybar manually

# Check Nix evaluation errors
nix flake check --show-trace
nix eval .#nixosConfigurations.hydenix.config.system.build.toplevel --show-trace
```

## Architecture

### Configuration Hierarchy
```
/nix-modules/
├── flake.nix                    # Flake inputs (hydenix, nixpkgs, grub2-themes)
├── configuration.nix            # Main system config (user: a, host: mini)
├── hardware-config.nix          # Smart hardware detection wrapper
└── modules/
    ├── system/                  # System-level modules (custom.system.*)
    │   ├── hardware/            # GPD Pocket 3 hardware support
    │   │   ├── auto-rotate.nix # Screen rotation service
    │   │   └── focal-spi/       # FTE3600 fingerprint reader
    │   ├── power/               # Power management
    │   │   ├── lid-behavior.nix # Lid close handling (set to ignore)
    │   │   └── suspend-control.nix
    │   ├── security/            # Security features
    │   │   ├── fingerprint.nix # fprintd configuration
    │   │   └── secrets.nix     # KeePassXC integration
    │   ├── packages/            # Custom packages
    │   │   ├── superclaude.nix # SuperClaude AI framework
    │   │   └── email.nix       # Proton Bridge + Thunderbird
    │   ├── auto-commit.nix     # Auto-commit on rebuild
    │   └── update-alias.nix    # update!, panic, worksummary commands
    └── hm/                      # Home Manager modules (custom.hm.*)
        ├── applications/        # User applications
        │   ├── firefox.nix     # Firefox with Cascade theme
        │   ├── ghostty.nix     # Main terminal emulator
        │   └── mpv.nix         # Video player config
        ├── audio/               # Audio configuration
        │   └── easyeffects.nix # Meze_109_Pro preset
        └── desktop/             # Desktop environment
            ├── auto-rotate.nix # User-level rotation
            ├── hypridle.nix    # Idle management
            └── waybar-fix.nix  # Waybar startup fix
```

### Module Namespaces
- **hydenix.***: Core Hydenix framework options
- **custom.system.***: System-level customizations
- **custom.hm.***: Home Manager (user-level) customizations

### Current Active Configuration
- **User**: `a` (password: `a`, groups: wheel, networkmanager, video, input)
- **Hostname**: `mini`
- **Shell**: `zsh`
- **Terminal**: `ghostty` (default)
- **Display**: DSI-1, 1200x1920@60, 1.5x scale, transform 3 (270° rotation)

## Hardware-Specific Features

### GPD Pocket 3 Support
- **Display**: DSI-1 with auto-rotation service
- **Touchscreen**: GXTP7380:00 27C6:0113 (event18)
- **Fingerprint**: FTE3600 via focal-spi kernel module
- **Gestures**: 3-finger swipe via hyprgrass plugin
- **Power**: Lid close ignored (prevents unwanted suspend)

### Working Features
- ✅ 3-finger horizontal swipe for workspace switching
- ✅ Fingerprint auth (SDDM login, sudo, swaylock)
- ✅ Screen auto-rotation based on device orientation
- ✅ Audio processing with EasyEffects (Meze_109_Pro preset)
- ✅ KeePassXC auto-start for secret management
- ✅ Auto-commit to GitHub on rebuild

### Known Issues
- ⚠️ Hyprgrass: Only 3-finger gestures work (2/4-finger not responding)
- ⚠️ Home Manager service may show as failed (config still applies)
- ⚠️ Fusuma disabled (Ruby gem installation failures in Nix)

## Development Workflow

### Making Configuration Changes
1. Edit relevant module file (use `sudo` for files in `/nix-modules/`)
2. Test with: `sudo nixos-rebuild test --flake .#hydenix --impure`
3. Apply permanently: `sudo nixos-rebuild switch --flake .#hydenix --impure`
4. Changes auto-commit to GitHub (or use `update!`)
5. If issues occur: `sudo nixos-rebuild switch --rollback`

### Adding New Modules
1. Create `.nix` file in appropriate directory:
   - System-wide: `modules/system/`
   - User-specific: `modules/hm/`
2. Define options under correct namespace:
   - System: `custom.system.myfeature`
   - User: `custom.hm.myfeature`
3. Import in parent `default.nix`
4. Enable in respective `default.nix` or configuration

### Package Management
- **System packages**: Add to `environment.systemPackages` in `modules/system/default.nix:105`
- **User packages**: Add to `home.packages` in `modules/hm/default.nix:106`
- **Custom derivations**: Create in `modules/system/packages/` (see superclaude.nix example)

### Testing and Validation
```bash
# Validate configuration syntax
nix flake check

# Test build without switching
sudo nixos-rebuild test --flake .#hydenix --impure

# Dry-run to see what would change
sudo nixos-rebuild dry-build --flake .#hydenix --impure

# Build and compare with current system
nixos-rebuild build --flake .#hydenix --impure && nvd diff /run/current-system result
```

## Important Implementation Details

### Hardware Detection (CRITICAL)
- **Always use `--impure` flag** for nixos-rebuild commands
- Hardware configuration uses smart detection via `hardware-config.nix:1`
- Falls back to placeholder when `/etc/nixos/hardware-configuration.nix` unavailable
- This allows GitHub sync without breaking local hardware config

### Auto-commit System
- Runs pre-activation before each rebuild (`modules/system/auto-commit.nix:6`)
- Commits all changes with timestamp
- Pushes to GitHub using `gh` CLI
- Prevents "dirty git tree" warnings during flake evaluation

### Module Option Patterns
System modules typically follow:
```nix
custom.system.feature = {
  enable = true;
  option1 = value;
};
```

Home Manager modules follow:
```nix
custom.hm.feature = {
  enable = true;
  option1 = value;
};
```

### Critical Files Reference
- `configuration.nix:75,87,89,103-105` - User setup and system identity
- `modules/system/default.nix:20-103` - All system module toggles
- `modules/hm/default.nix:13-84` - All user module toggles
- `hardware-config.nix:10-13` - Hardware detection logic
- `modules/system/update-alias.nix:6-46` - Quick command definitions
- `flake.nix:10-20` - Flake inputs and nixosConfiguration

## Tips and Warnings

### DO's
- ✅ Always rebuild with `--impure` flag
- ✅ Use `update!` for quick commits and rebuilds
- ✅ Check `journalctl -xe --user` when services fail
- ✅ Use `panic` or `A!` to quickly reset to GitHub state
- ✅ Use `sudo` when modifying files in `/nix-modules/`

### DON'Ts
- ❌ Never rebuild without `--impure` (breaks hardware detection)
- ❌ Don't commit secrets (will be world-readable in Nix store)
- ❌ Don't modify hardware-configuration.nix directly (use hardware-config.nix wrapper)
- ❌ Don't start waybar manually in exec-once (managed by HyDE)
- ❌ Don't forget to use sudo for system-level file edits