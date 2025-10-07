7
# Module API Reference

Complete reference for all `custom.system.*` and `custom.hm.*` configuration options in NaN.

## Table of Contents

- [System Modules](#system-modules)
  - [Monitor Configuration](#monitor-configuration)
  - [Hardware](#hardware)
  - [Security](#security)
  - [Network](#network)
  - [Power Management](#power-management)
  - [Display Management](#display-management)
  - [Input](#input)
  - [Packages](#packages)
  - [System Services](#system-services)
- [Home Manager Modules](#home-manager-modules)
  - [DWL Compositor](#dwl-compositor)
  - [Applications](#applications)
  - [Audio](#audio)
  - [Desktop Environment](#desktop-environment)

---

## System Modules

### Monitor Configuration

**`custom.system.monitor`** - Display configuration for GPD Pocket 3

```nix
custom.system.monitor = {
  enable = true;                    # Type: bool, Default: false
  name = "DSI-1";                   # Type: str, Display output name
  resolution = "1200x1920@60";      # Type: str, Resolution and refresh rate
  position = "0x0";                 # Type: str, Display position (x,y)
  scale = 1.5;                      # Type: float, HiDPI scaling factor
  transform = 3;                    # Type: int, Rotation (0=0°, 1=90°, 2=180°, 3=270°)
};
```

**Defined in**: `modules/system/monitor-config.nix`

---

### Hardware

#### Focaltech Fingerprint Reader

**`custom.system.hardware.focaltechFingerprint`** - Fingerprint sensor kernel module

```nix
custom.system.hardware.focaltechFingerprint = {
  enable = true;                    # Type: bool, Default: false
};
```

**Defined in**: `modules/system/hardware/focal-spi/default.nix`

---

#### Thermal Management

**`custom.system.hardware.thermal`** - CPU thermal monitoring and control

```nix
custom.system.hardware.thermal = {
  enable = true;                    # Type: bool, Default: false
  enableThermald = true;            # Type: bool, Default: true
  normalGovernor = "schedutil";     # Type: str, Default: "schedutil"
  emergencyShutdownTemp = 95;       # Type: int, Default: 95 (°C)
  criticalTemp = 90;                # Type: int, Default: 90 (°C)
  throttleTemp = 80;                # Type: int, Default: 85 (°C, overridden to 80 in system config)
};
```

**Thermal Zones** (Intel CPU):
- `thermal_zone5` = CPU package temperature (primary monitoring)
- `thermal_zone0` = ACPI thermal zone (secondary)
- Emergency actions: System shutdown at emergencyShutdownTemp
- Critical throttling: Min frequency + powersave governor at criticalTemp
- Throttling: Reduce max freq to 2.0GHz + powersave at throttleTemp

**Defined in**: `modules/system/hardware/thermal-management.nix`

---

#### Hardware Monitoring

**`custom.system.hardware.monitoring`** - System health monitoring service

```nix
custom.system.hardware.monitoring = {
  enable = true;                    # Type: bool, Default: false
};
```

Monitors: CPU temp, fan speed, battery, disk health, memory usage

**Defined in**: `modules/system/hardware/monitoring.nix`

---

#### ACPI Fixes

**`custom.system.hardware.acpiFixes`** - GPD Pocket 3 ACPI workarounds

```nix
custom.system.hardware.acpiFixes = {
  enable = true;                    # Type: bool, Default: false
  useOverride = true;               # Type: bool, Use DSDT override table
};
```

**Defined in**: `modules/system/hardware/acpi-fixes.nix`

---

#### Auto-Rotate

**`custom.system.hardware.autoRotate`** - Automatic display rotation via accelerometer

```nix
custom.system.hardware.autoRotate = {
  enable = true;                    # Type: bool, Default: false
};
```

**Defined in**: `modules/system/hardware/auto-rotate.nix`

---

### Security

#### Fingerprint Authentication

**`custom.system.security.fingerprint`** - PAM integration for fingerprint auth

```nix
custom.system.security.fingerprint = {
  enable = true;                    # Type: bool, Default: false
  enableSddm = true;                # Type: bool, Enable for SDDM login
  enableSudo = true;                # Type: bool, Enable for sudo authentication
  enableSwaylock = true;            # Type: bool, Enable for swaylock screen lock
};
```

**Enrollment**: `fprintd-enroll` (as user)  
**Verification**: `fprintd-verify` (as user)

**Defined in**: `modules/system/security/fingerprint.nix`

---

#### Security Hardening

**`custom.system.security.hardening`** - System-wide security policies

```nix
custom.system.security.hardening = {
  enable = true;                    # Type: bool, Default: false
  restrictSSH = true;               # Type: bool, Key-based auth only, no root login
  closeGamingPorts = false;         # Type: bool, Block Steam/gaming ports
};
```

**Features**:
- AppArmor enforcement
- Audit logging (auditd)
- Kernel module locking post-boot
- SSH restrictions (no password auth, no root)
- Git commit signing via SSH

**Defined in**: `modules/system/security/hardening.nix`

---

#### Secrets Management

**`custom.system.security.secrets`** - Secret storage backend

```nix
custom.system.security.secrets = {
  enable = true;                    # Type: bool, Default: false
  provider = "gnome-keyring";       # Type: enum, Options: "gnome-keyring" | "keepassxc"
};
```

**Defined in**: `modules/system/security/secrets.nix`

---

### Network

#### iPhone USB Tethering

**`custom.system.network.iphoneUsbTethering`** - Automatic iPhone USB connection

```nix
custom.system.network.iphoneUsbTethering = {
  enable = true;                    # Type: bool, Default: false
  autoConnect = true;               # Type: bool, Auto-connect on device plug-in
  connectionPriority = 15;          # Type: int, NetworkManager priority (higher = preferred)
};
```

**Defined in**: `modules/system/network/iphone-usb-tethering.nix`

---

### Power Management

#### Suspend Control

**`custom.system.power.suspendControl`** - Lid behavior and power settings

```nix
custom.system.power.suspendControl = {
  enable = true;                    # Type: bool, Default: false
  lidBehavior = "ignore";           # Type: enum, Options: "ignore" | "suspend" | "hibernate"
};
```

**Defined in**: `modules/system/power/suspend-control.nix`

---

### Display Management

**`custom.system.displayManagement`** - Wayland display tools

```nix
custom.system.displayManagement = {
  enable = true;                    # Type: bool, Default: false
  tools = {
    wlrRandr = true;                # Type: bool, CLI display configuration
    wdisplays = true;               # Type: bool, GUI display manager
    kanshi = true;                  # Type: bool, Dynamic display profiles
  };
};
```

**Defined in**: `modules/system/display-management.nix`

---

### Input

#### Keyd

**`custom.system.input.keyd`** - Keyboard remapping daemon

```nix
custom.system.input.keyd = {
  enable = true;                    # Type: bool, Default: false
};
```

**Defined in**: `modules/system/input/keyd.nix`

---

#### Vial

**`custom.system.input.vial`** - Keyboard configurator for QMK/VIA

```nix
custom.system.input.vial = {
  enable = true;                    # Type: bool, Default: false
};
```

**Defined in**: `modules/system/input/vial.nix`

---

### Packages

#### Email Clients

**`custom.system.packages.email`** - Email application suite

```nix
custom.system.packages.email = {
  enable = true;                    # Type: bool, Default: false
};
```

Includes: Thunderbird, aerc (terminal), neomutt

**Defined in**: `modules/system/packages/email.nix`

---

#### Display Rotation Tools

**`custom.system.packages.displayRotation`** - Screen orientation utilities

```nix
custom.system.packages.displayRotation = {
  enable = true;                    # Type: bool, Default: false
};
```

**Defined in**: `modules/system/packages/display-rotation.nix`

---

### System Services

#### Wayland Screenshare

**`custom.system.waylandScreenshare`** - Screen sharing support for Wayland

```nix
custom.system.waylandScreenshare = {
  enable = true;                    # Type: bool, Default: false
};
```

**Defined in**: `modules/system/wayland-screenshare.nix`

---

#### Backup

**`custom.system.backup`** - Restic backup configuration

```nix
custom.system.backup = {
  enable = true;                    # Type: bool, Default: false
  repository = "sftp:user@host:/path";  # Type: str, Restic repository URL
  passwordFile = "/etc/nixos/secrets/restic-password";  # Type: path
  paths = [ "/home" "/etc/nixos" ]; # Type: list of paths
  schedule = "daily";               # Type: str, Systemd timer schedule
};
```

**Defined in**: `modules/system/backup.nix`

---

#### MPD (System)

**`custom.system.mpd`** - System-level Music Player Daemon

```nix
custom.system.mpd = {
  enable = false;                   # Type: bool, Default: false
  # NOTE: Disabled by default to avoid port conflict with user MPD
};
```

**Defined in**: `modules/system/mpd.nix`

---

## Home Manager Modules

### DWL Compositor

**`custom.hm.dwl`** - DWL window manager configuration

```nix
custom.hm.dwl = {
  enable = true;                    # Type: bool, Default: false
};
```

**Includes**:
- DWL compositor with layer shell v3
- dwlb status bar with system info
- Status scripts: `~/.local/bin/dwl-status/status` (basic) and `status-enhanced`
- Session management (swaybg, dunst, dwlb, dwl)

**Defined in**: `modules/hm/dwl/default.nix`

---

### Applications

#### Firefox

**`custom.hm.applications.firefox`** - Firefox browser

```nix
custom.hm.applications.firefox = {
  enable = true;                    # Type: bool, Default: false
  enableCascade = true;             # Type: bool, Enable Cascade CSS theme
};
```

**Defined in**: `modules/hm/applications/firefox.nix`

---

#### Ghostty

**`custom.hm.applications.ghostty`** - Ghostty terminal emulator

```nix
custom.hm.applications.ghostty = {
  enable = true;                    # Type: bool, Default: false
};
```

**Defined in**: `modules/hm/applications/ghostty.nix`

---

#### MPV

**`custom.hm.applications.mpv`** - MPV media player

```nix
custom.hm.applications.mpv = {
  enable = true;                    # Type: bool, Default: false
  youtubeQuality = "1080";          # Type: str, YouTube playback quality
  hwdec = "auto";                   # Type: str, Hardware decoding (auto/vaapi/no)
};
```

**Defined in**: `modules/hm/applications/mpv.nix`

---

#### btop

**`custom.hm.applications.btop`** - System monitor

```nix
custom.hm.applications.btop = {
  enable = true;                    # Type: bool, Default: false
};
```

**Defined in**: `modules/hm/applications/btop.nix`

---

#### Music Players

**`custom.hm.applications.musicPlayers`** - Streaming music applications

```nix
custom.hm.applications.musicPlayers = {
  tidal = {
    enable = true;                  # Type: bool, Default: false
    suspendInhibit = true;          # Type: bool, Prevent suspend during playback
  };
};
```

**Defined in**: `modules/hm/applications/music-players.nix`

---

### Audio

#### MPD (User)

**`custom.hm.audio.mpd`** - User-level Music Player Daemon

```nix
custom.hm.audio.mpd = {
  enable = true;                    # Type: bool, Default: false
  musicDirectory = "~/Music";       # Type: path, Music library location
};
```

**Defined in**: `modules/hm/audio/mpd.nix`

---

#### EasyEffects

**`custom.hm.audio.easyeffects`** - Audio effects processing

```nix
custom.hm.audio.easyeffects = {
  enable = true;                    # Type: bool, Default: false
  preset = "Meze_109_Pro";          # Type: str, Audio preset name
};
```

**Available Presets**: Meze_109_Pro (headphone EQ)

**Defined in**: `modules/hm/audio/easyeffects.nix`

---

### Desktop Environment

#### Theme

**`custom.hm.desktop.theme`** - Desktop theming

```nix
custom.hm.desktop.theme = {
  catppuccinMochaTeal = true;       # Type: bool, Enable Catppuccin Mocha Teal theme
};
```

**Defined in**: `modules/hm/desktop/theme.nix`

---

#### Auto-Rotate Service

**`custom.hm.desktop.autoRotateService`** - Display auto-rotation

```nix
custom.hm.desktop.autoRotateService = {
  enable = true;                    # Type: bool, Default: false
};
```

**Defined in**: `modules/hm/desktop/auto-rotate-service.nix`

---

#### Touchscreen

**`custom.hm.desktop.touchscreen`** - Touchscreen calibration

```nix
custom.hm.desktop.touchscreen = {
  enable = true;                    # Type: bool, Default: false
  rotation = 270;                   # Type: int, Touchscreen rotation angle
};
```

**Defined in**: `modules/hm/desktop/touchscreen.nix`

---

#### Gestures

**`custom.hm.gestures`** - Touchpad/touchscreen gestures

```nix
custom.hm.gestures = {
  enable = true;                    # Type: bool, Default: false
};
```

**Defined in**: `modules/hm/desktop/gestures.nix`

---

#### Animations

**`custom.hm.animations`** - Wayland compositor animations

```nix
custom.hm.animations = {
  enable = true;                    # Type: bool, Default: false
  notifications = {
    enable = true;                  # Type: bool, Notification fade animations
    fadeTime = 200;                 # Type: int, Fade duration (ms)
  };
  compositor = {
    fadeWindows = true;             # Type: bool, Window fade in/out
    fadeDuration = 150;             # Type: int, Window fade duration (ms)
  };
};
```

**Defined in**: `modules/hm/desktop/animations.nix`

---

## Module Development

### Adding New Modules

1. **Create module file** in appropriate directory:
   - System modules: `modules/system/`
   - Home Manager modules: `modules/hm/`

2. **Follow module pattern**:
   ```nix
   { config, lib, pkgs, ... }:
   with lib;
   let cfg = config.custom.system.moduleName;
   in {
     options.custom.system.moduleName = {
       enable = mkEnableOption "description";
     };
     config = mkIf cfg.enable { /* implementation */ };
   }
   ```

3. **Import in parent `default.nix`**:
   ```nix
   imports = [ ./moduleName.nix ];
   ```

4. **Enable in configuration**:
   ```nix
   custom.system.moduleName.enable = true;
   ```

### Module Guidelines

- Use `custom.system.*` for system-level configuration
- Use `custom.hm.*` for user-level Home Manager configuration
- Always provide `enable` option with `mkEnableOption`
- Document all options with descriptions
- Use `mkIf cfg.enable` for conditional configuration
- Follow existing naming conventions

---

## See Also

- [ARCHITECTURE.md](ARCHITECTURE.md) - System design overview
- [CONTRIBUTING.md](CONTRIBUTING.md) - Development guidelines
- [README.md](README.md) - Installation and usage
