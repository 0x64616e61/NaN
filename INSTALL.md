# grOSs Installation Guide

## Fresh Installation

This guide covers installing grOSs on your GPD Pocket 3.

### Features

[+] GPD Pocket 3 hardware support:
    - Display rotation (270°), scaling (1.5x)
    - Thermal management (throttle at 80°C)
    - Fingerprint reader (FTE3600)
    - ACPI fixes
    - Power management

[+] System functionality:
    - Network (iPhone USB tethering)
    - Security (fingerprint auth, secrets, hardening)
    - Input (keyd, vial)
    - Audio (MPD, EasyEffects)
    - Minimal resource usage

### Installation Steps

#### Standard Installation

```bash
# 1. Clone grOSs
cd ~
git clone https://github.com/garmir/grOSs
cd grOSs

# 2. Copy your hardware config
sudo cp /etc/nixos/hardware-configuration.nix ./

# 3. Review configuration.nix
#    - Verify hostname, timezone, locale
#    - Check user settings

# 4. Build and switch
sudo nixos-rebuild switch --flake .#grOSs

# 5. Reboot
sudo reboot

# 6. At SDDM, select "dwl" session
```

#### Option 2: Test Build First

```bash
# Build without switching
sudo nixos-rebuild build --flake .#grOSs

# If successful, then switch
sudo nixos-rebuild switch --flake .#grOSs
```

### Post-Migration

#### Set Wallpaper

```bash
# Place your wallpaper at:
~/.config/wallpaper.png
```

#### Status Bar

somebar reads from stdin. The default status script shows:
- Battery level and charging status
- Time and date

Located at: `~/.local/bin/dwl-status/status`

Customize by editing the script.

#### Key Bindings

DWL uses default dwm bindings. To customize, edit config.h and rebuild.

### Display Rotation

All rotation commands from Hydenix work (they use `wlr-randr`):

```bash
rotate-landscape        # 270° (GPD Pocket 3 default)
rotate-portrait         # 0°
dual-displays          # Internal + external monitor
display-reset          # Reset to defaults
```

### Troubleshooting

#### DWL session not in SDDM

```bash
# Rebuild
sudo nixos-rebuild switch --flake .#grOSs
```

#### Fingerprint not working

```bash
# Check fingerprint service
systemctl status fprintd

# Re-enroll
fprintd-enroll
```

#### Display rotation wrong

```bash
# Manually set rotation
wlr-randr --output DSI-1 --transform 3 --scale 1.5

# Or use preset
rotate-landscape
```

### Rollback

Boot into previous generation from GRUB:

1. Reboot
2. At GRUB, select "NixOS - All Generations"
3. Choose generation before grOSs
4. Boot


### Updating grOSs

```bash
cd ~/grOSs
git pull
sudo nixos-rebuild switch --flake .#grOSs
```
