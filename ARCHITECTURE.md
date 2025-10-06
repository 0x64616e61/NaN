7
# Architecture Overview

System design and module organization for NaN NixOS configuration.

## Design Principles

1. **Modular Configuration**: Everything organized as reusable modules with clean interfaces
2. **Custom Options Framework**: All settings use `custom.*` namespace for consistency
3. **Hardware-First Design**: Optimized specifically for GPD Pocket 3 characteristics
4. **Security by Default**: Hardening enabled out-of-the-box with minimal attack surface
5. **Declarative Everything**: No imperative state, fully reproducible builds

---

## System Architecture

### Configuration Flow

```
flake.nix
├── nixpkgs (unstable)
├── home-manager
└── nixos-hardware (GPD Pocket 3 profile)
    │
    ├── configuration.nix ─────────────► Main system config
    │   ├── User account (a)
    │   ├── Hostname (NaN)
    │   ├── SDDM display manager
    │   └── System packages
    │
    ├── gpd-pocket-3.nix ──────────────► Hardware optimizations
    │   ├── Systemd initrd
    │   ├── Display rotation (fbcon, video=DSI-1)
    │   ├── Touchscreen calibration
    │   └── Audio fixes
    │
    ├── hardware-config.nix ───────────► Auto-generated hardware
    │
    └── modules/
        ├── system/ ───────────────────► System-level modules
        │   ├── default.nix ───────────► custom.system.* options
        │   ├── boot.nix
        │   ├── plymouth.nix
        │   ├── hardware/ ─────────────► Hardware integration
        │   │   ├── thermal-management.nix
        │   │   ├── focal-spi/  ───────► Fingerprint sensor
        │   │   ├── monitoring.nix
        │   │   ├── acpi-fixes.nix
        │   │   └── auto-rotate.nix
        │   ├── security/ ─────────────► Security hardening
        │   │   ├── fingerprint.nix
        │   │   ├── hardening.nix
        │   │   └── secrets.nix
        │   ├── network/
        │   │   └── iphone-usb-tethering.nix
        │   ├── power/
        │   │   └── suspend-control.nix
        │   └── input/
        │       ├── keyd.nix
        │       └── vial.nix
        │
        └── hm/ ───────────────────────► Home Manager modules
            ├── default.nix ───────────► custom.hm.* options
            ├── dwl/ ──────────────────► DWL compositor
            │   └── status-scripts/  ──► dwlb status bar
            ├── applications/
            │   ├── firefox.nix
            │   ├── ghostty.nix
            │   ├── mpv.nix
            │   └── music-players.nix
            ├── audio/
            │   ├── mpd.nix
            │   └── easyeffects.nix
            └── desktop/
                ├── theme.nix
                ├── gestures.nix
                ├── touchscreen.nix
                ├── animations.nix
                └── auto-rotate-service.nix
```

---

## Module Organization

### System Modules (`modules/system/`)

**Purpose**: System-level configuration requiring root privileges

| Category | Modules | Responsibility |
|----------|---------|----------------|
| **Boot** | boot.nix, plymouth.nix | Fast boot optimization, boot splash |
| **Hardware** | thermal, monitoring, focal-spi, acpi-fixes, auto-rotate | Hardware integration and drivers |
| **Security** | fingerprint, hardening, secrets | Authentication, hardening, secret storage |
| **Network** | iphone-usb-tethering | Network device integration |
| **Power** | suspend-control | Power management and lid behavior |
| **Display** | monitor-config, display-management, grub-theme | Display configuration and theming |
| **Input** | keyd, vial | Keyboard remapping and configuration |
| **Packages** | email, display-rotation | Application bundles |

### Home Manager Modules (`modules/hm/`)

**Purpose**: User-level configuration for user 'a'

| Category | Modules | Responsibility |
|----------|---------|----------------|
| **DWL** | dwl/default.nix | Window manager, status bar, session |
| **Applications** | firefox, ghostty, mpv, btop, music-players | User applications |
| **Audio** | mpd, easyeffects | Music playback and audio processing |
| **Desktop** | theme, gestures, touchscreen, animations, auto-rotate | User environment customization |

---

## Hardware Integration Patterns

### GPD Pocket 3 Specifics

#### Display (1200x1920 Portrait Native)

```
Boot Loader (GRUB)
│
├── gfxmodeEfi = "1200x1920x32"
└── Rotated theme assets
    │
Kernel (Linux)
│
├── fbcon=rotate:1  ──────────────────► Console rotation (270°)
└── video=DSI-1:panel_orientation=right_side_up
    │
Wayland (DWL)
│
├── DSI-1 output
├── Resolution: 1200x1920@60
├── Transform: 3 (270° rotation)
└── Scale: 1.5 (HiDPI)
```

#### Touchscreen Calibration

```
Hardware Event
│
├── GXTP7380:00 27C6:0113  ──────► Touchscreen device
│
udev Rule
│
├── LIBINPUT_CALIBRATION_MATRIX
└── "0 1 0 -1 0 1"  ──────────────► 90° clockwise transform
    │
libinput
│
└── Rotated touch coordinates
```

#### Thermal Management

```
Sensors
│
├── thermal_zone5 ────────────────► CPU package temp (primary)
│
Monitor Service (5s intervals)
│
├── > 95°C ───────────────────────► Emergency shutdown
├── > 90°C ───────────────────────► Critical governor change
└── > 80°C ───────────────────────► Throttle (max 2.0GHz)
    │
Logs: /var/log/thermal-monitor.log
```

---

## Configuration Patterns

### Module Template

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
    
    option1 = mkOption {
      type = types.str;
      default = "value";
      description = "Option description";
    };
  };

  config = mkIf cfg.enable {
    # Implementation here
    environment.systemPackages = [ pkgs.package ];
    services.serviceName.enable = true;
  };
}
```

### Option Naming Convention

```
custom.system.*     ─────► System-level options (requires root)
custom.hm.*         ─────► Home Manager options (user-level)

Examples:
custom.system.hardware.thermal.enable
custom.system.security.fingerprint.enableSddm
custom.hm.applications.firefox.enableCascade
custom.hm.audio.mpd.musicDirectory
```

---

## Security Architecture

### Defense in Depth

```
Network Layer
│
├── SSH: Key-based auth only, no root login
└── Firewall: Optional gaming port blocking
    │
System Layer
│
├── AppArmor: Mandatory access control
├── Audit: Full system event logging
└── Kernel: Module loading locked post-boot
    │
Authentication Layer
│
├── Fingerprint (fprintd + PAM)
├── Password fallback
└── Integration: SDDM, sudo, swaylock
    │
Secrets Management
│
├── gnome-keyring (default)
└── keepassxc (alternative)
```

### Security Defaults

- **No default password**: Must be set manually on first boot
- **SSH hardening**: Key-based only, root login disabled
- **Git signing**: SSH-based commit signing enabled
- **Kernel hardening**: Module locking prevents runtime module insertion
- **AppArmor**: Enforcing mode for confined services

---

## Boot Optimization

### Boot Sequence

```
UEFI/GRUB (1s timeout)
│
├── Kernel parameters: quiet splash loglevel=3
│
Systemd Initrd (parallel)
│
├── xhci_pci, thunderbolt, nvme, usb_storage (parallel load)
├── i915 (early Intel GPU initialization)
└── zstd -1 compression (fastest decompression)
    │
System Services
│
├── Disabled: NetworkManager-wait-online
├── Disabled: systemd-udev-settle
└── Fast startup: thermald, fprintd, sddm
    │
SDDM Display Manager
│
└── Target: <10 second boot time
```

### Boot Configuration

- **Systemd initrd**: Parallel device initialization
- **Minimal services**: Disabled unnecessary wait states
- **Fast compression**: zstd -1 for quick decompression
- **Silent boot**: Minimal console output

---

## Design Decisions

### Why DWL?

- **Minimal**: ~2000 SLOC vs i3's ~20,000
- **Wayland-native**: Modern protocol, better security
- **Layer shell v3**: Native status bar support (dwlb)
- **dwm philosophy**: Simple, hackable, keyboard-driven

### Why Custom Options Framework?

- **Consistency**: All options under `custom.*` namespace
- **Discoverability**: `nix repl` can explore all options
- **Modularity**: Enable/disable features with single boolean
- **Type safety**: Nix type checking prevents invalid configs

### Why No Flake?

Actually, **NaN USES flakes**! The file `flake.nix.disabled` indicates a previous non-flake iteration, but the system now fully utilizes:
- Flake inputs for dependency pinning
- `nixosConfigurations.NaN` for system definition
- Home Manager as flake module

### Why System-Level Hardware Modules?

GPD Pocket 3 hardware requires root-level access:
- **Kernel modules**: Fingerprint sensor driver
- **udev rules**: Touchscreen calibration
- **Thermal management**: CPU governor control
- **ACPI overrides**: Hardware quirk fixes

User-level modules couldn't access these privileged interfaces.

---

## Performance Characteristics

| Metric | Target | Actual |
|--------|--------|--------|
| Boot time (UEFI → SDDM) | <10s | ~8-10s |
| Display rotation | Instant | <100ms |
| Thermal response | <5s | 5s intervals |
| Status bar update | 1-2s | 2s refresh |
| Memory footprint (idle) | <2GB | ~1.5GB |

---

## Future Architecture

### Potential Improvements

1. **Flake modules**: Extract reusable modules for other devices
2. **Secrets management**: Integrate sops-nix or agenix
3. **Home Manager standalone**: Separate user configs from system
4. **Multi-device support**: Abstract GPD Pocket 3-specific code
5. **Testing framework**: Automated NixOS VM tests

---

## See Also

- [MODULE_API.md](MODULE_API.md) - Complete options reference
- [CONTRIBUTING.md](CONTRIBUTING.md) - Development guidelines
- [README.md](README.md) - Installation and usage
