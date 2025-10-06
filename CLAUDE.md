# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**grOSs** is a production-ready NixOS configuration for the GPD Pocket 3 handheld device, featuring:
- DWL Wayland compositor (dwm for Wayland)
- Complete GPD Pocket 3 hardware integration
- Modular custom options framework
- Security hardening with AppArmor
- Performance-optimized boot (<10s target)

## System Architecture

### Configuration Entry Points

```
flake.nix                    # Flake inputs: nixpkgs, home-manager, nixos-hardware
├── configuration.nix        # Main system config (hostname, users, SDDM)
├── hardware-config.nix      # Hardware-specific settings (auto-generated)
└── modules/
    ├── system/              # System-level modules (custom.system.*)
    │   └── default.nix      # System module aggregator
    └── hm/                  # Home Manager modules (custom.hm.*)
        └── default.nix      # User module aggregator
```

### Custom Options Framework

All configuration uses the `custom.*` namespace for declarative module control:

**System modules** (`custom.system.*` in `modules/system/default.nix`):
- `monitor.*` - Display configuration for GPD Pocket 3 (1200x1920@60, 270° rotation)
- `hardware.focaltechFingerprint.*` - Focaltech fingerprint sensor
- `hardware.thermal.*` - Thermal management (emergencyShutdownTemp, throttleTemp)
- `hardware.monitoring.*` - Hardware health monitoring service
- `security.hardening.*` - SSH restrictions, AppArmor, audit logging
- `security.fingerprint.*` - PAM integration for SDDM/sudo/swaylock
- `power.lidBehavior.*` - Lid close action (ignore/suspend/hibernate)
- `network.iphoneUsbTethering.*` - Auto-connect iPhone USB tethering

**Home Manager modules** (`custom.hm.*` in `modules/hm/default.nix`):
- `dwl.enable` - DWL compositor with status bar scripts
- `applications.*` - Firefox, Ghostty, MPV, btop configurations
- `audio.*` - MPD, EasyEffects with presets
- `desktop.*` - Auto-rotate, touchscreen, gestures, theming
- `animations.*` - Wayland compositor animations

### Module Pattern

Every module follows this structure:

```nix
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.system.moduleName;
in
{
  options.custom.system.moduleName = {
    enable = mkEnableOption "feature description";
    # Additional options...
  };

  config = mkIf cfg.enable {
    # Implementation...
  };
}
```

## Building and Testing

### Standard Build Commands

```bash
# Full system rebuild (activates immediately)
sudo nixos-rebuild switch --flake .#grOSs

# Test without boot entry (temporary activation)
sudo nixos-rebuild test --flake .#grOSs

# Build for next boot only (no immediate activation)
sudo nixos-rebuild boot --flake .#grOSs

# Dry-run validation (check for errors without building)
sudo nixos-rebuild dry-build --flake .#grOSs

# Update flake inputs
nix flake update

# Build without activation (creates result symlink)
sudo nixos-rebuild build --flake .#grOSs
```

### Flake Configuration

The system uses three flake inputs:
- `nixpkgs` (nixos-unstable)
- `home-manager` (follows nixpkgs)
- `nixos-hardware` (GPD Pocket 3 profile at `nixosModules.gpd-pocket-3`)

Home Manager is integrated as a NixOS module with:
- `useGlobalPkgs = true`
- `useUserPackages = true`
- `users.a = import ./modules/hm`

## GPD Pocket 3 Hardware Specifics

### Display Configuration

The GPD Pocket 3 has a native **portrait 1200x1920@60Hz** display. The system rotates it to landscape:

- GRUB bootloader: Uses rotated theme assets with `gfxmodeEfi = "1200x1920x32"`
- Kernel: `fbcon=rotate:1` + `video=DSI-1:panel_orientation=right_side_up`
- Wayland: `transform = 3` (270° rotation) in monitor config
- Display name: **DSI-1**

### Fingerprint Reader

Focaltech fingerprint sensor integration:
- Custom kernel module in `modules/system/hardware/focal-spi/`
- PAM integration via fprintd
- Enrollment: `fprintd-enroll` / verification: `fprintd-verify`

### Thermal Management

Critical thermal zones for Intel CPUs:
- **thermal_zone5**: x86_pkg_temp (actual CPU package temperature)
- Emergency shutdown: 95°C (default)
- Critical throttle: 90°C (emergency governor change)
- Throttle: 80°C (reduce max frequency to 2.0GHz)
- Monitor script: `/var/log/thermal-monitor.log`

### DWL Compositor

DWL session starts via SDDM with:
1. `swaybg` for wallpaper (`~/.config/wallpaper.png` or solid color fallback)
2. `dunst` for notifications
3. `dwlb` status bar fed by `~/.local/bin/dwl-status/status`
4. DWL compositor (`${pkgs.dwl}/bin/dwl`)

Status bar scripts:
- Basic: `~/.local/bin/dwl-status/status` (battery, time, date)
- Enhanced: `~/.local/bin/dwl-status/status-enhanced` (CPU, memory, disk, network, temp)

## Common Development Workflows

### Adding a New Module

1. Create module file in appropriate directory:
   ```bash
   # System module
   touch modules/system/new-feature.nix

   # Home Manager module
   touch modules/hm/new-feature.nix
   ```

2. Define module with custom options:
   ```nix
   { config, lib, pkgs, ... }:
   with lib;
   let cfg = config.custom.system.newFeature;
   in {
     options.custom.system.newFeature = {
       enable = mkEnableOption "description";
     };
     config = mkIf cfg.enable { /* ... */ };
   }
   ```

3. Import in parent `default.nix`:
   ```nix
   imports = [ ./new-feature.nix ];
   ```

4. Enable in `modules/system/default.nix` or `modules/hm/default.nix`:
   ```nix
   custom.system.newFeature.enable = true;
   ```

5. Test: `sudo nixos-rebuild test --flake .#grOSs`

### Modifying Hardware Configuration

**Thermal thresholds** (`modules/system/default.nix`):
```nix
custom.system.hardware.thermal = {
  emergencyShutdownTemp = 95;  # °C
  throttleTemp = 80;
  normalGovernor = "schedutil";  # or "performance"/"powersave"
};
```

**Display settings**:
```nix
custom.system.monitor = {
  resolution = "1200x1920@60";
  scale = 1.5;           # HiDPI scaling
  transform = 3;         # 0=0°, 1=90°, 2=180°, 3=270°
};
```

**Fingerprint authentication**:
```nix
custom.system.security.fingerprint = {
  enableSddm = true;     # Login screen
  enableSudo = true;     # Terminal sudo
  enableSwaylock = true; # Screen lock
};
```

### Security Configuration

The system has default weak credentials that **must be changed**:
- User `a` has no password set (must run `sudo passwd a` after install)
- Git config uses placeholder email `mini@nix`

Security hardening includes:
- SSH: Key-based auth only, no root login (`custom.system.security.hardening.restrictSSH`)
- Kernel: `lockKernelModules = true` (prevents runtime module loading after boot)
- AppArmor: Enabled with confinement profiles
- Audit: Full system event logging via auditd
- Git: SSH-based commit signing enabled

### Boot Optimization

Boot configuration in `modules/system/boot.nix`:
- Systemd-based initrd (faster than traditional)
- Zstd compression level -1 (fastest)
- Disabled services: `NetworkManager-wait-online`, `systemd-udev-settle`
- Kernel params: `nowatchdog`, `quiet`, `splash`
- GRUB timeout: 1 second

To adjust boot timeout:
```nix
boot.loader.timeout = 5;  # in boot.nix
```

## Important File Locations

### System Configuration
- `/etc/nixos` - This repository when installed
- `/boot` - EFI mount point
- `/var/log/thermal-monitor.log` - Thermal events
- `/var/log/fan-control.log` - Fan control events

### User Configuration
- `~/.local/bin/dwl-status/status` - Status bar script
- `~/.config/wallpaper.png` - DWL background image
- `~/.ssh/id_ed25519.pub` - Git commit signing key

### Hardware Paths
- `/sys/class/thermal/thermal_zone5/temp` - CPU package temperature (millidegrees)
- `/sys/class/power_supply/BAT0/` - Battery status
- `/sys/class/backlight/*/brightness` - Display brightness control
- `/sys/devices/system/cpu/cpu*/cpufreq/` - CPU frequency scaling

## Debugging Common Issues

### DWL won't start after SDDM login
```bash
# Check DWL startup errors
journalctl -xe | grep dwl

# Verify status bar script exists
ls -la ~/.local/bin/dwl-status/status

# Rebuild home-manager config
sudo nixos-rebuild switch --flake .#grOSs
```

### Fingerprint reader not detected
```bash
# Check USB device presence
lsusb | grep Focal

# Verify fprintd service
systemctl status fprintd

# Re-enroll fingerprint
fprintd-enroll
```

### Thermal throttling occurring
```bash
# Monitor temperatures in real-time
watch sensors

# Check thermal monitor logs
journalctl -u thermal-monitor -f

# View detailed thermal events
tail -f /var/log/thermal-monitor.log
```

### Display rotation incorrect
```bash
# Check current display configuration
wlr-randr

# Available transforms: 0 (0°), 1 (90°), 2 (180°), 3 (270°)
# Modify in modules/system/default.nix:
custom.system.monitor.transform = 3;
```

## Module Organization

### System Modules (`modules/system/`)
- `boot.nix` - GRUB, Plymouth, fast boot optimizations
- `backup.nix` - System backup configuration
- `hardware/` - Fingerprint, thermal, ACPI, auto-rotate, monitoring
- `power/` - Battery optimization, lid behavior, suspend control
- `security/` - Hardening, fingerprint PAM, secrets (keepassxc/gnome-keyring)
- `network/` - iPhone USB tethering
- `input/` - keyd remapping, Vial keyboard configurator
- `packages/` - Email clients, display rotation tools

### Home Manager Modules (`modules/hm/`)
- `dwl/` - DWL compositor configuration and status scripts
- `applications/` - Firefox, Ghostty, MPV, btop
- `audio/` - MPD, EasyEffects
- `desktop/` - Theme (Catppuccin), gestures, touchscreen, auto-rotate, animations

## Performance Characteristics

- **Boot time target**: <10 seconds to SDDM
- **Status bar update**: 1-2 second intervals
- **Thermal monitoring**: 5 second intervals (configurable)
- **Display scale**: 1.5x for readability on 7" 1920p screen
- **Memory optimization**: swappiness=10, dirty_ratio=15

## Critical Rules

1. **Always test before switching**: Use `sudo nixos-rebuild test` for major changes
2. **Custom namespace only**: Use `custom.system.*` or `custom.hm.*` for new options
3. **Module imports**: Add new modules to `default.nix` imports list
4. **Security defaults**: Never commit with weak passwords or placeholder credentials
5. **GPD-specific paths**: Use DSI-1 for display, thermal_zone5 for CPU temp
6. **Home Manager integration**: User configs go in `modules/hm/`, system configs in `modules/system/`
