# NixOS Configuration Architecture Analysis

## System Overview

This is a modular NixOS configuration with 61 Nix modules organized in a two-tier hierarchical structure. The system uses Hydenix as the base framework with custom extensions specifically optimized for GPD Pocket 3 hardware.

## Configuration Flow

```
flake.nix:47-48 → nixosConfigurations.hydenix & .mini (aliases)
    ↓
configuration.nix:28-30 → imports custom modules
    ↓
hardware-config.nix:10-13 → smart hardware detection wrapper
    ↓
modules/system/default.nix:20-178 → system-level configuration
modules/hm/default.nix:13-99 → user-level configuration
```

## Module Namespaces

### Three-Tier Option System:
1. **hydenix.***: Core Hydenix framework options (configuration.nix:101-108)
2. **custom.system.***: System-level customizations (modules/system/default.nix:20-178)
3. **custom.hm.***: Home Manager user-level customizations (modules/hm/default.nix:13-99)

## Hardware Detection Mechanism

**Smart Configuration Wrapper** (hardware-config.nix:10-13):
- Checks for `/etc/nixos/hardware-configuration.nix` in impure mode
- Falls back to local placeholder when unavailable
- Enables GitHub sync without breaking local hardware config
- **Critical**: Always use `--impure` flag for hardware detection

## Module Organization (61 Total Files)

### System Modules (modules/system/)
- **hardware/**: GPD Pocket 3 specific (auto-rotate, focal-spi fingerprint, monitoring)
- **power/**: Battery optimization, lid behavior, suspend control
- **security/**: Fingerprint auth, secrets management (KeePassXC)
- **packages/**: Custom derivations (superclaude, email, display-rotation)
- **input/**: Keyboard/gesture configuration (keyd, vial)
- **Individual modules**: boot, plymouth, monitor-config, display-management, grub-theme, mpd, wayland-screenshare

### Home Manager Modules (modules/hm/)
- **applications/**: User apps (firefox, ghostty, mpv, btop, kitty)
- **audio/**: EasyEffects with Meze_109_Pro preset
- **desktop/**: 13 modules for Hyprland environment
  - Gesture handling (hyprgrass-config, libinput-gestures, fusuma)
  - Auto-rotation (auto-rotate, auto-rotate-service)
  - Waybar customization (waybar-fix, waybar-rotation-lock, waybar-rotation-patch)
  - Terminal integration (workflows-ghostty, hyprland-ghostty, hyde-ghostty)
  - Theme and idle management (theme, hypridle)

## Key Architecture Patterns

### Module Aggregation Pattern
Each directory has a `default.nix` that imports child modules:
- `modules/system/default.nix:4-17` → imports all system subdirectories
- `modules/hm/default.nix:4-10` → imports all hm subdirectories
- `modules/system/hardware/default.nix:3-7` → imports hardware-specific modules

### Option Definition Pattern
System modules use `custom.system.*` namespace:
```nix
custom.system.hardware.autoRotate = {
  enable = true;
  monitor = "DSI-1";
  scale = 1.5;
};
```

Home Manager modules use `custom.hm.*` namespace:
```nix
custom.hm.desktop.autoRotateService = {
  enable = true;
};
```

### Hardware-Specific Optimizations
- **Display**: DSI-1 @ 1200x1920, 1.5x scale, 270° rotation (configuration.nix:112)
- **Touchscreen**: GXTP7380:00 27C6:0113 gesture support
- **Fingerprint**: FTE3600 via focal-spi kernel module
- **Power**: Lid close ignored, thermal protection enabled

## Critical Implementation Details

### Auto-commit System
- Pre-activation hooks commit changes before rebuild
- Prevents "dirty git tree" warnings during flake evaluation
- Enabled via `modules/system/auto-commit.nix` (imported in configuration.nix:29)

### Dual Configuration Support
- `hydenix` and `mini` both point to same configuration (flake.nix:47-48)
- Allows hostname-based rebuilds: `sudo nixos-rebuild switch --flake .#mini`

### Package Management Split
- **System packages**: `environment.systemPackages` (modules/system/default.nix:180-209)
- **User packages**: `home.packages` (modules/hm/default.nix:122-124)
- **Custom derivations**: modules/system/packages/ directory

## Module Dependencies

### Critical Dependencies
- Hydenix framework (flake.nix:15)
- nixos-hardware.nixosModules.gpd-pocket-3 (configuration.nix:39)
- grub2-themes (flake.nix:25-28, configuration.nix:41)
- nix-index-database (flake.nix:19-22, configuration.nix:80)

### Service Orchestration
- Auto-rotate service coordination between system and user levels
- Waybar management through HyDE framework
- Gesture handling via multiple backends (hyprgrass primary, libinput fallback)

This architecture enables a highly modular, hardware-optimized NixOS configuration with clear separation of concerns and systematic organization patterns.