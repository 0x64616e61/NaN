# grOSs - Minimal Wayland OS for GPD Pocket 3

A declarative, modular NixOS configuration tailored for the GPD Pocket 3 handheld device, featuring the DWL compositor and comprehensive hardware integration.

## Overview

grOSs is a **production-ready NixOS system** designed specifically for the GPD Pocket 3's unique hardware characteristics:

- **Minimal Wayland environment** with DWL compositor
- **Portrait display optimization** (1200x1920 native resolution)
- **Complete hardware support** (fingerprint, touchscreen, thermal management)
- **Security-hardened** with AppArmor, audit logging, and SSH restrictions
- **Performance-optimized** boot and power management

### System Specifications

- **Compositor**: DWL (dwm for Wayland)
- **Status Bar**: dwlb (layer shell v3 compatible)
- **Display Manager**: SDDM
- **Hardware Platform**: GPD Pocket 3
- **NixOS Version**: 25.11 (unstable)
- **Configuration Files**: 53 Nix modules (5,835 lines)

## Quick Start

### Prerequisites

- GPD Pocket 3 hardware (or compatible x86_64 device)
- NixOS installation media
- Basic familiarity with NixOS and Nix flakes

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url> /etc/nixos
   cd /etc/nixos
   ```

2. **Review hardware configuration**
   ```bash
   # Ensure hardware-config.nix matches your system
   nixos-generate-config --show-hardware-config
   ```

3. **🚨 CRITICAL: Set user password**
   ```bash
   # BEFORE BUILDING: Remove or change the default password
   # Edit configuration.nix line 39 and either:
   # - Remove: initialPassword = "a";
   # - Or set a secure password hash:
   # users.users.a.hashedPassword = "$(mkpasswd -m sha-512)";
   ```

4. **Build and activate**
   ```bash
   sudo nixos-rebuild switch --flake .#grOSs
   ```

5. **Reboot into grOSs**
   ```bash
   sudo reboot
   ```

See [INSTALLATION.md](INSTALLATION.md) for detailed installation instructions and troubleshooting.

## Key Features

### 🖥️ Wayland Compositor

- **DWL**: Lightweight, tiling Wayland compositor based on dwm principles
- **dwlb**: Modern status bar with layer shell v3 support
- **Custom keybindings**: Optimized for GPD Pocket 3's compact keyboard
- **Touchscreen support**: Native Wayland touch input integration

### 🔐 Security Hardening

- **AppArmor**: Mandatory access control with profile confinement
- **SSH hardening**: Key-based authentication only, root login disabled
- **Audit logging**: Comprehensive system event tracking
- **Firewall**: Enabled with connection logging
- **Kernel security**: dmesg restriction, BPF hardening, unprivileged BPF disabled
- **Git commit signing**: Automatic SSH-based commit signing

**⚠️ See [SECURITY.md](SECURITY.md) for critical security setup requirements**

### 🎯 GPD Pocket 3 Hardware Integration

#### Display
- **Native portrait resolution**: 1200x1920@60Hz with automatic rotation
- **Custom GRUB theme**: Rotated assets for landscape appearance
- **Display tools**: wlr-randr, wdisplays, kanshi integration
- **Auto-rotate service**: Automatic orientation detection

#### Input Devices
- **Focaltech fingerprint sensor**: PAM integration for SDDM, sudo, swaylock
- **Keyd**: Keyboard remapping and customization
- **Touchscreen & pen**: Full Wayland input support
- **Gesture recognition**: Custom gesture handlers

#### Thermal & Power Management
- **Thermald integration**: Intelligent thermal throttling
- **Custom thermal zones**: Emergency shutdown at 95°C, throttle at 80°C
- **Battery optimization**: TLP integration with auto-cpufreq
- **Hardware monitoring**: Systemd service tracking temps, battery, storage health
- **Lid behavior**: Configurable lid close actions (default: ignore)

#### Connectivity
- **iPhone USB tethering**: Auto-connect with priority routing
- **NetworkManager**: WiFi and wired networking
- **Bluetooth**: Full BlueZ integration

### ⚡ Performance Optimizations

- **Fast boot**: Systemd-based initrd with zstd compression (~10s boot target)
- **Memory tuning**: Low swappiness (10), optimized dirty page ratios
- **Service optimization**: Disabled network-wait and udev-settle delays
- **Kernel parameters**: `nowatchdog`, minimal logging for speed

### 🧩 Modular Architecture

grOSs uses a **custom options framework** for declarative configuration:

```nix
custom.system = {
  # Hardware features
  hardware.focaltechFingerprint.enable = true;
  hardware.thermal.enable = true;

  # Security settings
  security.hardening.enable = true;
  security.fingerprint.enable = true;

  # Power management
  power.lidBehavior.action = "ignore";

  # Network configuration
  network.iphoneUsbTethering.enable = true;
};
```

See [MODULES.md](MODULES.md) for complete module reference.

## Project Structure

```
/home/a/grOSs/
├── flake.nix                    # Flake configuration with inputs
├── configuration.nix            # Main system configuration
├── hardware-config.nix          # Hardware-specific settings
│
├── modules/
│   ├── system/                  # System-level modules
│   │   ├── boot.nix            # Boot optimization & GRUB config
│   │   ├── security/           # Security hardening modules
│   │   ├── hardware/           # Hardware support (fingerprint, thermal, etc.)
│   │   ├── power/              # Power management modules
│   │   ├── network/            # Network configuration
│   │   └── packages/           # System package modules
│   │
│   └── hm/                      # Home Manager user configuration
│       ├── applications/        # User application configs
│       ├── desktop/            # Desktop environment settings
│       ├── audio/              # Audio configuration (MPD, EasyEffects)
│       └── dwl/                # DWL compositor configuration
│
└── tests/                       # Test configurations (optional)
```

See [ARCHITECTURE.md](ARCHITECTURE.md) for detailed system design documentation.

## Configuration Highlights

### Custom Module Options

All configuration is centralized under `custom.system.*` and `custom.hm.*` namespaces:

| Module | Purpose | Key Options |
|--------|---------|-------------|
| `hardware.focaltechFingerprint` | Fingerprint sensor support | `enable` |
| `hardware.thermal` | Thermal management | `emergencyShutdownTemp`, `throttleTemp` |
| `hardware.monitoring` | Hardware health monitoring | `alerts.method`, `checkInterval` |
| `security.hardening` | Security hardening | `restrictSSH`, `closeGamingPorts` |
| `security.fingerprint` | Fingerprint auth | `enableSddm`, `enableSudo` |
| `security.secrets` | Secret storage | `provider` (keepassxc/gnome-keyring) |
| `power.lidBehavior` | Lid close behavior | `action` (ignore/suspend/hibernate) |
| `power.suspendControl` | Suspend configuration | `disableCompletely` |
| `network.iphoneUsbTethering` | iPhone tethering | `autoConnect`, `connectionPriority` |

### Flake Inputs

- **nixpkgs**: NixOS unstable channel
- **home-manager**: User environment management
- **nixos-hardware**: GPD Pocket 3 hardware profile

## Usage

### Building the System

```bash
# Full system rebuild
sudo nixos-rebuild switch --flake .#grOSs

# Test configuration without activation
sudo nixos-rebuild test --flake .#grOSs

# Build boot configuration only
sudo nixos-rebuild boot --flake .#grOSs
```

### Updating the System

```bash
# Update flake inputs
nix flake update

# Rebuild with updated inputs
sudo nixos-rebuild switch --flake .#grOSs
```

### Hardware Monitoring

```bash
# Manual hardware check
sudo gpd-hardware-monitor

# View monitoring logs
journalctl -u gpd-hardware-monitor -f

# Check current temperatures
sensors
```

### Fingerprint Enrollment

```bash
# Enroll fingerprint for current user
fprintd-enroll

# Verify fingerprint
fprintd-verify

# List enrolled fingerprints
fprintd-list a
```

## Customization

### Changing Display Settings

Edit `modules/system/default.nix`:

```nix
custom.system.monitor = {
  enable = true;
  name = "DSI-1";
  resolution = "1200x1920@60";
  scale = 1.5;  # Adjust for readability
  transform = 3;  # 270° rotation
};
```

### Adjusting Thermal Thresholds

Edit `modules/system/default.nix`:

```nix
custom.system.hardware.thermal = {
  enable = true;
  emergencyShutdownTemp = 95;  # °C
  criticalTemp = 90;
  throttleTemp = 80;
  normalGovernor = "schedutil";  # or "performance"/"powersave"
};
```

### Security Provider Configuration

Choose secret storage backend:

```nix
custom.system.security.secrets = {
  enable = true;
  provider = "gnome-keyring";  # or "keepassxc"
};
```

## Troubleshooting

### Common Issues

**DWL won't start after login**
- Check: `journalctl -xe | grep dwl`
- Verify: Status bar script exists at `~/.local/bin/dwl-status/status`
- Fix: Rebuild with `nixos-rebuild switch`

**Fingerprint reader not working**
- Check: `lsusb | grep Focal`
- Verify: `systemctl status fprintd`
- Enroll: `fprintd-enroll`

**Display rotation incorrect**
- Check: `wlr-randr`
- Adjust: `transform` option in monitor config (0=0°, 1=90°, 2=180°, 3=270°)

**High temperatures/thermal throttling**
- Monitor: `watch sensors`
- Check: `journalctl -u gpd-hardware-monitor`
- Adjust: Thermal thresholds in configuration

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for comprehensive troubleshooting guide.

## Development

### Adding New Modules

1. Create module file in appropriate directory:
   ```bash
   # System module
   touch modules/system/feature-name.nix

   # Home Manager module
   touch modules/hm/feature-name.nix
   ```

2. Define module structure:
   ```nix
   { config, lib, pkgs, ... }:

   with lib;

   let
     cfg = config.custom.system.featureName;
   in
   {
     options.custom.system.featureName = {
       enable = mkEnableOption "feature description";
       # Additional options...
     };

     config = mkIf cfg.enable {
       # Configuration implementation...
     };
   }
   ```

3. Import in parent module:
   ```nix
   # modules/system/default.nix or modules/hm/default.nix
   imports = [
     ./feature-name.nix
   ];
   ```

4. Test configuration:
   ```bash
   sudo nixos-rebuild test --flake .#grOSs
   ```

### Testing Changes

```bash
# Dry-run to check for errors
sudo nixos-rebuild dry-build --flake .#grOSs

# Build without activation
sudo nixos-rebuild build --flake .#grOSs

# Test with activation but no boot entry
sudo nixos-rebuild test --flake .#grOSs
```

## Documentation

- **[ARCHITECTURE.md](ARCHITECTURE.md)** - System design and architectural decisions
- **[INSTALLATION.md](INSTALLATION.md)** - Detailed installation guide
- **[MODULES.md](MODULES.md)** - Complete module reference
- **[SECURITY.md](SECURITY.md)** - Security hardening guide and requirements
- **[SYSTEM_ANALYSIS_REPORT.md](SYSTEM_ANALYSIS_REPORT.md)** - Comprehensive system analysis

## Contributing

This is a personal NixOS configuration, but contributions and suggestions are welcome:

1. Fork the repository
2. Create a feature branch
3. Test changes on GPD Pocket 3 hardware (or similar)
4. Submit pull request with description

### Contribution Guidelines

- Follow existing Nix code style conventions
- Add comments for complex logic
- Update module documentation for new options
- Test on actual hardware when possible
- Keep modules focused and single-responsibility

## Security Notice

**🚨 CRITICAL**: Before deploying this configuration:

1. **Remove the default password** in `configuration.nix:39`
2. **Set a strong user password** using `hashedPassword`
3. **Review firewall rules** for your use case
4. **Consider enabling disk encryption** (LUKS)
5. **Review SSH configuration** if enabling remote access

See [SECURITY.md](SECURITY.md) for complete security hardening checklist.

## License

This configuration is provided as-is for personal use. Adapt and modify as needed for your hardware and requirements.

## Acknowledgments

- **NixOS Community** - For the excellent NixOS distribution
- **DWL Project** - For the lightweight Wayland compositor
- **nixos-hardware** - For GPD Pocket 3 hardware profiles
- **home-manager** - For declarative user environment management

## Support

For issues specific to:
- **grOSs configuration**: Open an issue in this repository
- **GPD Pocket 3 hardware**: Check [nixos-hardware GPD Pocket 3 profile](https://github.com/NixOS/nixos-hardware/tree/master/gpd/pocket-3)
- **NixOS general**: Visit [NixOS Discourse](https://discourse.nixos.org/)
- **DWL compositor**: See [DWL project documentation](https://github.com/djpohly/dwl)

## System Health

**Current Status**: Production-ready with security fixes required

| Category | Score | Status |
|----------|-------|--------|
| Architecture | 9.0/10 | ✅ Excellent |
| Security | 6.5/10 | ⚠️ Fix required |
| Performance | 8.5/10 | ✅ Optimized |
| Hardware Integration | 9.5/10 | ✅ Exceptional |
| **Overall** | **8.2/10** | ✅ Good |

Last system analysis: See [SYSTEM_ANALYSIS_REPORT.md](SYSTEM_ANALYSIS_REPORT.md)

---

**grOSs** - Minimal, secure, and performant NixOS for GPD Pocket 3
