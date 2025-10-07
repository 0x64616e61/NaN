# File Reference Guide

Quick lookup for file paths and locations in the NaN NixOS configuration.

---

## 🗂️ Quick File Lookup

### Core Configuration Files

| File | Path | Purpose |
|------|------|---------|
| **Flake** | `/etc/nixos/flake.nix` | Flake inputs and outputs |
| **User Config** | `/etc/nixos/config-variables.nix` | Username, hostname, hardware profile |
| **Main Config** | `/etc/nixos/configuration.nix` | System configuration |
| **Hardware Config** | `/etc/nixos/hardware-config.nix` | Auto-generated hardware settings |
| **GPD Config** | `/etc/nixos/gpd-pocket-3.nix` | GPD Pocket 3 optimizations |

### Module Entry Points

| Module Type | Path | Purpose |
|-------------|------|---------|
| **System Modules** | `/etc/nixos/modules/system/default.nix` | System module aggregator (`custom.system.*`) |
| **User Modules** | `/etc/nixos/modules/hm/default.nix` | Home Manager aggregator (`custom.hm.*`) |

---

## 📦 System Modules

### Boot and Display

| Feature | File Path |
|---------|-----------|
| **Boot Optimization** | `/etc/nixos/modules/system/boot.nix` |
| **Boot Splash** | `/etc/nixos/modules/system/plymouth.nix` |
| **GRUB Theme** | `/etc/nixos/modules/system/grub-theme.nix` |
| **Monitor Config** | `/etc/nixos/modules/system/monitor-config.nix` |
| **Display Tools** | `/etc/nixos/modules/system/display-management.nix` |

### Hardware Integration

| Feature | File Path |
|---------|-----------|
| **Thermal Management** | `/etc/nixos/modules/system/hardware/thermal-management.nix` |
| **System Monitoring** | `/etc/nixos/modules/system/hardware/monitoring.nix` |
| **ACPI Fixes** | `/etc/nixos/modules/system/hardware/acpi-fixes.nix` |
| **Auto-Rotate** | `/etc/nixos/modules/system/hardware/auto-rotate.nix` |
| **Focal-SPI Driver** | `/etc/nixos/modules/system/hardware/focal-spi/kernel-module.nix` |
| **Libfprint Patch** | `/etc/nixos/modules/system/hardware/focal-spi/libfprint-focaltech.nix` |
| **Focal Aggregator** | `/etc/nixos/modules/system/hardware/focal-spi/default.nix` |
| **Hardware Aggregator** | `/etc/nixos/modules/system/hardware/default.nix` |

### Security

| Feature | File Path |
|---------|-----------|
| **Fingerprint Auth** | `/etc/nixos/modules/system/security/fingerprint.nix` |
| **System Hardening** | `/etc/nixos/modules/system/security/hardening.nix` |
| **Secrets Management** | `/etc/nixos/modules/system/security/secrets.nix` |
| **Security Aggregator** | `/etc/nixos/modules/system/security/default.nix` |

### Network and Power

| Feature | File Path |
|---------|-----------|
| **iPhone USB Tethering** | `/etc/nixos/modules/system/network/iphone-usb-tethering.nix` |
| **Network Aggregator** | `/etc/nixos/modules/system/network/default.nix` |
| **Suspend Control** | `/etc/nixos/modules/system/power/suspend-control.nix` |
| **Power Aggregator** | `/etc/nixos/modules/system/power/default.nix` |

### Input Devices

| Feature | File Path |
|---------|-----------|
| **Keyd Remapping** | `/etc/nixos/modules/system/input/keyd.nix` |
| **Vial Configurator** | `/etc/nixos/modules/system/input/vial.nix` |
| **Input Aggregator** | `/etc/nixos/modules/system/input/default.nix` |

### Package Bundles

| Feature | File Path |
|---------|-----------|
| **Email Clients** | `/etc/nixos/modules/system/packages/email.nix` |
| **Display Rotation** | `/etc/nixos/modules/system/packages/display-rotation.nix` |
| **Package Aggregator** | `/etc/nixos/modules/system/packages/default.nix` |

### System Services

| Feature | File Path |
|---------|-----------|
| **Backup System** | `/etc/nixos/modules/system/backup.nix` |
| **System MPD** | `/etc/nixos/modules/system/mpd.nix` |
| **Wayland Screenshare** | `/etc/nixos/modules/system/wayland-screenshare.nix` |
| **DWL Custom** | `/etc/nixos/modules/system/dwl-custom.nix` |
| **DWL Keybinds** | `/etc/nixos/modules/system/dwl-keybinds.nix` |
| **Touchscreen/Pen** | `/etc/nixos/modules/system/touchscreen-pen.nix` |
| **Update Alias** | `/etc/nixos/modules/system/update-alias.nix` |

---

## 🏠 Home Manager Modules

### DWL Compositor

| Feature | File Path |
|---------|-----------|
| **DWL Config** | `/etc/nixos/modules/hm/dwl/default.nix` |

### Applications

| Feature | File Path |
|---------|-----------|
| **Firefox** | `/etc/nixos/modules/hm/applications/firefox.nix` |
| **Ghostty Terminal** | `/etc/nixos/modules/hm/applications/ghostty.nix` |
| **MPV Player** | `/etc/nixos/modules/hm/applications/mpv.nix` |
| **btop Monitor** | `/etc/nixos/modules/hm/applications/btop.nix` |
| **Music Players** | `/etc/nixos/modules/hm/applications/music-players.nix` |
| **App Aggregator** | `/etc/nixos/modules/hm/applications/default.nix` |

### Audio System

| Feature | File Path |
|---------|-----------|
| **User MPD** | `/etc/nixos/modules/hm/audio/mpd.nix` |
| **EasyEffects** | `/etc/nixos/modules/hm/audio/easyeffects.nix` |
| **Audio Aggregator** | `/etc/nixos/modules/hm/audio/default.nix` |

### Desktop Environment

| Feature | File Path |
|---------|-----------|
| **Theme** | `/etc/nixos/modules/hm/desktop/theme.nix` |
| **Touchscreen** | `/etc/nixos/modules/hm/desktop/touchscreen.nix` |
| **Gestures** | `/etc/nixos/modules/hm/desktop/gestures.nix` |
| **Animations** | `/etc/nixos/modules/hm/desktop/animations.nix` |
| **Auto-Rotate Service** | `/etc/nixos/modules/hm/desktop/auto-rotate-service.nix` |
| **Desktop Aggregator** | `/etc/nixos/modules/hm/desktop/default.nix` |

---

## 📖 Documentation Files

### Primary Documentation

| Document | Path | Purpose |
|----------|------|---------|
| **Project Overview** | `/etc/nixos/README.md` | Main documentation |
| **Installation Guide** | `/etc/nixos/INSTALL.md` | Setup instructions |
| **Quick Reference** | `/etc/nixos/QUICK_REFERENCE.md` | Command cheat sheet |
| **Developer Guide** | `/etc/nixos/CLAUDE.md` | AI assistant documentation |

### Architecture Documentation

| Document | Path | Purpose |
|----------|------|---------|
| **System Architecture** | `/etc/nixos/ARCHITECTURE.md` | Design patterns |
| **Module API** | `/etc/nixos/MODULE_API.md` | Complete options reference |
| **Project Index** | `/etc/nixos/PROJECT_INDEX.md` | Master navigation |
| **Dependency Graph** | `/etc/nixos/MODULE_DEPENDENCY_GRAPH.md` | Module relationships |
| **File Reference** | `/etc/nixos/FILE_REFERENCE.md` | This file |

### Development Documentation

| Document | Path | Purpose |
|----------|------|---------|
| **Contributing Guide** | `/etc/nixos/CONTRIBUTING.md` | Development guidelines |
| **Deployment Guide** | `/etc/nixos/DEPLOYMENT.md` | Deployment procedures |

### Feature-Specific Documentation

| Document | Path | Purpose |
|----------|------|---------|
| **DWL Keybindings** | `/etc/nixos/docs/DWL_KEYBINDINGS.md` | Complete keybindings |
| **Lock Screen** | `/etc/nixos/docs/LOCK_SCREEN_INTEGRATION.md` | Lock screen config |
| **Animations** | `/etc/nixos/docs/GPD_POCKET_3_ANIMATIONS.md` | Animation system |

---

## 🔧 Runtime File Locations

### System Configuration

| Resource | Path | Purpose |
|----------|------|---------|
| **NixOS Config** | `/etc/nixos/` | This repository |
| **Boot Partition** | `/boot/` | EFI bootloader |
| **Thermal Log** | `/var/log/thermal-monitor.log` | Thermal events |

### User Configuration

| Resource | Path | Purpose |
|----------|------|---------|
| **DWL Status Script** | `~/.local/bin/dwl-status/status` | Status bar basic |
| **DWL Status Enhanced** | `~/.local/bin/dwl-status/status-enhanced` | Status bar advanced |
| **DWL Startup** | `~/.local/bin/start-dwl` | DWL session launcher |
| **Wallpaper** | `~/.config/wallpaper.png` | Desktop background |
| **Git Signing Key** | `~/.ssh/id_ed25519.pub` | Commit signing |
| **Swaylock Config** | `~/.config/swaylock/config` | Lock screen |

### Hardware Sysfs Paths

| Resource | Path | Purpose |
|----------|------|---------|
| **CPU Temperature** | `/sys/class/thermal/thermal_zone5/temp` | CPU temp (millidegrees) |
| **Battery Capacity** | `/sys/class/power_supply/BAT0/capacity` | Battery percentage |
| **Battery Status** | `/sys/class/power_supply/BAT0/status` | Charging status |
| **Backlight** | `/sys/class/backlight/*/brightness` | Display brightness |
| **CPU Frequency** | `/sys/devices/system/cpu/cpu*/cpufreq/` | CPU scaling |
| **CPU Governor** | `/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor` | Current governor |

---

## 🔍 Finding Files by Feature

### By Configuration Option

| Option | Configuration File |
|--------|-------------------|
| **custom.system.monitor** | `/etc/nixos/modules/system/monitor-config.nix` |
| **custom.system.hardware.thermal** | `/etc/nixos/modules/system/hardware/thermal-management.nix` |
| **custom.system.hardware.focaltechFingerprint** | `/etc/nixos/modules/system/hardware/focal-spi/default.nix` |
| **custom.system.security.fingerprint** | `/etc/nixos/modules/system/security/fingerprint.nix` |
| **custom.system.security.hardening** | `/etc/nixos/modules/system/security/hardening.nix` |
| **custom.system.network.iphoneUsbTethering** | `/etc/nixos/modules/system/network/iphone-usb-tethering.nix` |
| **custom.hm.dwl** | `/etc/nixos/modules/hm/dwl/default.nix` |
| **custom.hm.applications.firefox** | `/etc/nixos/modules/hm/applications/firefox.nix` |
| **custom.hm.audio.mpd** | `/etc/nixos/modules/hm/audio/mpd.nix` |
| **custom.hm.desktop.theme** | `/etc/nixos/modules/hm/desktop/theme.nix` |

### By Hardware Feature

| Feature | Module Files |
|---------|--------------|
| **Fingerprint Reader** | `focal-spi/kernel-module.nix`, `focal-spi/libfprint-focaltech.nix`, `security/fingerprint.nix` |
| **Display** | `monitor-config.nix`, `display-management.nix`, `grub-theme.nix`, `gpd-pocket-3.nix` |
| **Thermal** | `hardware/thermal-management.nix` |
| **Touchscreen** | `touchscreen-pen.nix`, `desktop/touchscreen.nix` |
| **Auto-Rotate** | `hardware/auto-rotate.nix`, `desktop/auto-rotate-service.nix` |
| **Battery** | `gpd-pocket-3.nix` (TLP optimization) |

### By Service

| Service | Module Files |
|---------|--------------|
| **SDDM** | `configuration.nix`, `security/fingerprint.nix` (enableSddm) |
| **DWL** | `modules/hm/dwl/default.nix`, `dwl-custom.nix`, `dwl-keybinds.nix` |
| **MPD** | `modules/system/mpd.nix` (disabled), `modules/hm/audio/mpd.nix` (enabled) |
| **fprintd** | `security/fingerprint.nix` |
| **thermald** | `hardware/thermal-management.nix` |
| **thermal-monitor** | `hardware/thermal-management.nix` |
| **NetworkManager** | `configuration.nix`, `network/iphone-usb-tethering.nix` |

---

## 📂 Directory Structure

```
/etc/nixos/
├── config-variables.nix
├── configuration.nix
├── flake.lock
├── flake.nix
├── gpd-pocket-3.nix
├── hardware-config.nix
├── hardware-configuration-fallback.nix
│
├── modules/
│   ├── system/
│   │   ├── default.nix
│   │   ├── backup.nix
│   │   ├── boot.nix
│   │   ├── display-management.nix
│   │   ├── dwl-custom.nix
│   │   ├── dwl-keybinds.nix
│   │   ├── grub-theme.nix
│   │   ├── monitor-config.nix
│   │   ├── mpd.nix
│   │   ├── plymouth.nix
│   │   ├── touchscreen-pen.nix
│   │   ├── update-alias.nix
│   │   ├── wayland-screenshare.nix
│   │   │
│   │   ├── hardware/
│   │   │   ├── default.nix
│   │   │   ├── acpi-fixes.nix
│   │   │   ├── auto-rotate.nix
│   │   │   ├── monitoring.nix
│   │   │   ├── thermal-management.nix
│   │   │   └── focal-spi/
│   │   │       ├── default.nix
│   │   │       ├── kernel-module.nix
│   │   │       └── libfprint-focaltech.nix
│   │   │
│   │   ├── input/
│   │   │   ├── default.nix
│   │   │   ├── keyd.nix
│   │   │   └── vial.nix
│   │   │
│   │   ├── network/
│   │   │   ├── default.nix
│   │   │   └── iphone-usb-tethering.nix
│   │   │
│   │   ├── packages/
│   │   │   ├── default.nix
│   │   │   ├── display-rotation.nix
│   │   │   └── email.nix
│   │   │
│   │   ├── power/
│   │   │   ├── default.nix
│   │   │   └── suspend-control.nix
│   │   │
│   │   └── security/
│   │       ├── default.nix
│   │       ├── fingerprint.nix
│   │       ├── hardening.nix
│   │       └── secrets.nix
│   │
│   └── hm/
│       ├── default.nix
│       │
│       ├── applications/
│       │   ├── default.nix
│       │   ├── btop.nix
│       │   ├── firefox.nix
│       │   ├── ghostty.nix
│       │   ├── mpv.nix
│       │   └── music-players.nix
│       │
│       ├── audio/
│       │   ├── default.nix
│       │   ├── easyeffects.nix
│       │   └── mpd.nix
│       │
│       ├── desktop/
│       │   ├── default.nix
│       │   ├── animations.nix
│       │   ├── auto-rotate-service.nix
│       │   ├── gestures.nix
│       │   ├── theme.nix
│       │   └── touchscreen.nix
│       │
│       └── dwl/
│           └── default.nix
│
└── docs/
    ├── DWL_KEYBINDINGS.md
    ├── GPD_POCKET_3_ANIMATIONS.md
    └── LOCK_SCREEN_INTEGRATION.md
```

---

## 🚀 Quick Access Patterns

### Finding a Module by Name

```bash
# Search for module by name
find /etc/nixos/modules -name "*fingerprint*"
# Result: modules/system/security/fingerprint.nix

# Search for module by option
grep -r "custom.system.hardware.thermal" /etc/nixos/modules
# Result: modules/system/hardware/thermal-management.nix
```

### Finding Documentation for a Feature

```bash
# Search documentation by keyword
grep -r "fingerprint" /etc/nixos/*.md
# Results: CLAUDE.md, MODULE_API.md, QUICK_REFERENCE.md

# List all documentation files
ls /etc/nixos/*.md /etc/nixos/docs/*.md
```

### Finding Configuration Examples

```bash
# View enabled system modules
cat /etc/nixos/modules/system/default.nix | grep "enable = true"

# View enabled user modules
cat /etc/nixos/modules/hm/default.nix | grep "enable = true"
```

---

## 🔧 Common File Modification Tasks

### Change Display Settings

**File:** `/etc/nixos/modules/system/default.nix`

```nix
custom.system.monitor = {
  enable = true;
  resolution = "1200x1920@60";  # Modify
  scale = 1.5;                  # Modify
  transform = 3;                # Modify (0=0°, 1=90°, 2=180°, 3=270°)
};
```

### Adjust Thermal Thresholds

**File:** `/etc/nixos/modules/system/default.nix`

```nix
custom.system.hardware.thermal = {
  emergencyShutdownTemp = 95;  # Modify (°C)
  criticalTemp = 90;           # Modify (°C)
  throttleTemp = 80;           # Modify (°C)
  normalGovernor = "schedutil"; # Modify (performance/powersave/schedutil)
};
```

### Enable/Disable Applications

**File:** `/etc/nixos/modules/hm/default.nix`

```nix
custom.hm.applications = {
  firefox.enable = true;   # Enable/disable
  ghostty.enable = true;   # Enable/disable
  mpv.enable = true;       # Enable/disable
  btop.enable = true;      # Enable/disable
};
```

### Customize User Information

**File:** `/etc/nixos/config-variables.nix`

```nix
{
  user = {
    name = "a";              # Change username
    description = "a";       # Change full name
    homeDirectory = "/home/a";
  };
  hostname = "NaN";          # Change hostname
  hardwareProfile = "gpd-pocket-3";  # Change hardware profile
}
```

---

## 📊 File Statistics

| Category | File Count | Total Lines (approx) |
|----------|------------|---------------------|
| **System Modules** | 35 files | ~3,500 lines |
| **Home Manager Modules** | 17 files | ~1,700 lines |
| **Core Config** | 6 files | ~800 lines |
| **Documentation** | 14 files | ~8,500 lines |
| **Total** | **72 files** | **~14,500 lines** |

---

## 🔗 See Also

- [PROJECT_INDEX.md](PROJECT_INDEX.md) - Master navigation
- [MODULE_DEPENDENCY_GRAPH.md](MODULE_DEPENDENCY_GRAPH.md) - Module relationships
- [MODULE_API.md](MODULE_API.md) - Complete options reference
- [ARCHITECTURE.md](ARCHITECTURE.md) - System design patterns

---

*Last Updated: 2025-10-07*
