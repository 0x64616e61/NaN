7
# NaN

> **Production-ready NixOS configuration for GPD Pocket 3**  
> Minimal Wayland system with DWL compositor, complete hardware integration, and security hardening

<div align="center">

![NixOS](https://img.shields.io/badge/NixOS-25.05-5277C3.svg?style=flat&logo=nixos&logoColor=white)
![GPD Pocket 3](https://img.shields.io/badge/Hardware-GPD_Pocket_3-orange?style=flat)
![DWL](https://img.shields.io/badge/Compositor-DWL-green?style=flat)
![License](https://img.shields.io/badge/License-MIT-blue.svg?style=flat)

**[Features](#-features)** • **[Quick Start](#-quick-start)** • **[Documentation](#-documentation)** • **[Contributing](#-contributing)**

</div>

---

## 🎯 What is NaN?

**NaN** (grOSs) is a fully declarative NixOS configuration optimized for the GPD Pocket 3 handheld PC. It combines the minimalism of DWL with comprehensive hardware support, creating a fast, secure, and ergonomic Linux environment for the unique 7" portrait display.

### Why NaN?

- ⚡ **Fast**: <10s boot time with optimized systemd-based initrd
- 🔒 **Secure**: AppArmor, audit logging, SSH hardening out-of-the-box
- 🧩 **Modular**: 53 custom modules with clean `custom.*` options API
- 🎨 **Complete**: Fingerprint auth, thermal management, auto-rotation, theming
- 📚 **Documented**: Comprehensive API reference and architecture docs

---

## ✨ Features

### 🖥️ **Wayland Environment**

- **DWL** - Lightweight tiling compositor (dwm for Wayland)
- **dwlb** - Status bar with layer shell v3 support
- **SDDM** - Display manager with fingerprint integration
- Custom keybindings optimized for compact keyboard
- Native touchscreen and stylus support

### 🔐 **Security Hardening**

- ✅ AppArmor mandatory access control
- ✅ SSH key-based auth only (no passwords, no root)
- ✅ System-wide audit logging (auditd)
- ✅ Kernel hardening (dmesg restrictions, BPF hardening)
- ✅ Git commit signing via SSH
- ✅ Fingerprint authentication (PAM integration)

### 🎯 **GPD Pocket 3 Integration**

| Feature | Status | Details |
|---------|--------|---------|
| **Display** | ✅ Full | 1200x1920→landscape rotation, HiDPI scaling |
| **Fingerprint** | ✅ Full | Focaltech sensor with PAM (SDDM/sudo/swaylock) |
| **Touchscreen** | ✅ Full | Calibrated 10-point touch + stylus |
| **Thermal** | ✅ Full | Emergency shutdown @95°C, throttle @80°C |
| **Auto-rotate** | ✅ Full | IIO sensor integration |
| **Gestures** | ✅ Full | Multi-touch gesture recognition |
| **Battery** | ✅ Full | TLP optimization + monitoring |
| **iPhone Tether** | ✅ Full | Auto-connect USB tethering |

### ⚙️ **Performance Optimizations**

```
Boot Time:        ~10 seconds (UEFI → SDDM)
Memory (Idle):    ~1.5 GB
Status Bar:       2s refresh interval
Thermal Monitor:  5s interval monitoring
```

- Systemd-based initrd with parallel device init
- zstd -1 compression (fastest decompression)
- Disabled network-wait and udev-settle delays
- Kernel params: `nowatchdog`, `quiet`, `splash`

---

## 🚀 Quick Start

### Prerequisites

- GPD Pocket 3 (or compatible x86_64 device)
- NixOS installation media
- Basic Nix/NixOS knowledge

### Installation

```bash
# 1. Clone repository
git clone https://github.com/0x64616e61/NaN.git /etc/nixos
cd /etc/nixos

# 2. Generate your hardware config
sudo nixos-generate-config --show-hardware-config > hardware-config.nix

# 3. Review and customize
# Edit modules/system/default.nix and modules/hm/default.nix

# 4. Build system
sudo nixos-rebuild switch --flake .#grOSs

# 5. Reboot
sudo reboot
```

**⚠️ IMPORTANT**: No default password is set. After first boot, run:
```bash
sudo passwd a  # Set password for user 'a'
```

See **[INSTALL.md](INSTALL.md)** for detailed installation guide.

---

## 📦 Module System

NaN uses a custom options framework with all settings under `custom.*` namespace:

### System Modules (`custom.system.*`)

```nix
custom.system = {
  # Hardware
  hardware.focaltechFingerprint.enable = true;
  hardware.thermal = {
    enable = true;
    emergencyShutdownTemp = 95;  # °C
    throttleTemp = 80;
  };

  # Security
  security.hardening.enable = true;
  security.fingerprint = {
    enable = true;
    enableSddm = true;
    enableSudo = true;
  };

  # Network
  network.iphoneUsbTethering = {
    enable = true;
    autoConnect = true;
  };
};
```

### Home Manager Modules (`custom.hm.*`)

```nix
custom.hm = {
  # Window manager
  dwl.enable = true;

  # Applications
  applications.firefox.enable = true;
  applications.ghostty.enable = true;

  # Audio
  audio.mpd.enable = true;
  audio.easyeffects.preset = "Meze_109_Pro";

  # Desktop
  desktop.theme.catppuccinMochaTeal = true;
  desktop.touchscreen.rotation = 270;
  animations.enable = true;
};
```

**Full API Reference**: [MODULE_API.md](MODULE_API.md)

---

## 📁 Project Structure

```
.
├── configuration.nix          # Main system config
├── gpd-pocket-3.nix          # GPD-specific optimizations
├── hardware-config.nix        # Auto-generated hardware config
├── flake.lock                # Locked dependencies
│
├── modules/
│   ├── system/               # System-level (root) modules
│   │   ├── boot.nix         # Fast boot configuration
│   │   ├── hardware/        # Fingerprint, thermal, monitoring
│   │   ├── security/        # Hardening, fingerprint, secrets
│   │   ├── network/         # iPhone tethering
│   │   └── power/           # Battery, lid behavior
│   │
│   └── hm/                   # Home Manager (user) modules
│       ├── dwl/             # DWL compositor + status bar
│       ├── applications/    # Firefox, Ghostty, MPV, etc.
│       ├── audio/           # MPD, EasyEffects
│       └── desktop/         # Theme, gestures, animations
│
└── docs/                     # Feature documentation
    ├── DWL_KEYBINDINGS.md
    ├── GPD_POCKET_3_ANIMATIONS.md
    └── LOCK_SCREEN_INTEGRATION.md
```

---

## 🛠️ Common Tasks

### Building & Testing

```bash
# Dry-run (check for errors)
sudo nixos-rebuild dry-build --flake .#grOSs

# Test without boot entry
sudo nixos-rebuild test --flake .#grOSs

# Build for next boot
sudo nixos-rebuild boot --flake .#grOSs

# Full rebuild (activate + boot entry)
sudo nixos-rebuild switch --flake .#grOSs
```

### Updating

```bash
# Update flake inputs
nix flake update

# Rebuild with updates
sudo nixos-rebuild switch --flake .#grOSs
```

### Fingerprint Setup

```bash
# Enroll fingerprint
fprintd-enroll

# Verify fingerprint
fprintd-verify

# List enrolled fingerprints
fprintd-list a
```

### Monitoring

```bash
# CPU temperature
sensors

# Thermal logs
journalctl -u thermal-monitor -f

# Battery status
cat /sys/class/power_supply/BAT0/capacity
```

---

## 📖 Documentation

| Document | Description |
|----------|-------------|
| **[MODULE_API.md](MODULE_API.md)** | Complete `custom.*` options reference |
| **[ARCHITECTURE.md](ARCHITECTURE.md)** | System design and patterns |
| **[CONTRIBUTING.md](CONTRIBUTING.md)** | Development guidelines |
| **[INSTALL.md](INSTALL.md)** | Detailed installation guide |
| **[QUICK_REFERENCE.md](QUICK_REFERENCE.md)** | Command cheat sheet |
| **[docs/](docs/)** | Feature-specific documentation |

---

## 🎨 Customization Examples

### Change Display Settings

```nix
# modules/system/default.nix
custom.system.monitor = {
  enable = true;
  resolution = "1200x1920@60";
  scale = 1.5;        # Adjust for readability
  transform = 3;      # 0=0°, 1=90°, 2=180°, 3=270°
};
```

### Adjust Thermal Limits

```nix
# modules/system/default.nix
custom.system.hardware.thermal = {
  emergencyShutdownTemp = 95;  # Emergency shutdown
  throttleTemp = 80;           # Start throttling
  normalGovernor = "schedutil"; # powersave/performance/schedutil
};
```

### Enable Applications

```nix
# modules/hm/default.nix
custom.hm.applications = {
  firefox.enable = true;
  ghostty.enable = true;
  mpv = {
    enable = true;
    youtubeQuality = "1080";
  };
};
```

---

## 🐛 Troubleshooting

<details>
<summary><b>DWL won't start after login</b></summary>

```bash
# Check DWL errors
journalctl -xe | grep dwl

# Verify status bar exists
ls -la ~/.local/bin/dwl-status/status

# Rebuild
sudo nixos-rebuild switch --flake .#grOSs
```
</details>

<details>
<summary><b>Fingerprint reader not detected</b></summary>

```bash
# Check USB device
lsusb | grep Focal

# Check service
systemctl status fprintd

# Re-enroll
fprintd-enroll
```
</details>

<details>
<summary><b>Display rotation incorrect</b></summary>

```bash
# Check current config
wlr-randr

# Adjust transform in modules/system/default.nix
# 0=0°, 1=90°, 2=180°, 3=270°
```
</details>

<details>
<summary><b>High CPU temperatures</b></summary>

```bash
# Monitor temps
watch sensors

# Check thermal logs
journalctl -u thermal-monitor -f

# Lower thresholds in modules/system/default.nix
```
</details>

---

## 🤝 Contributing

Contributions welcome! This is a personal config, but improvements benefit everyone.

### How to Contribute

1. Fork the repository
2. Create feature branch: `git checkout -b feature/my-module`
3. Make changes following [CONTRIBUTING.md](CONTRIBUTING.md)
4. Test on hardware: `sudo nixos-rebuild test --flake .#grOSs`
5. Commit: `git commit -m "feat: add feature"`
6. Push: `git push origin feature/my-module`
7. Open Pull Request

### Contribution Guidelines

- ✅ Follow existing Nix code style
- ✅ Use `custom.system.*` or `custom.hm.*` namespaces
- ✅ Add options documentation
- ✅ Test on actual hardware when possible
- ✅ Update MODULE_API.md for new options

---

## 📜 License

MIT License - Feel free to use, modify, and distribute.

---

## 🙏 Acknowledgments

- **[NixOS](https://nixos.org/)** - The purely functional Linux distribution
- **[DWL](https://github.com/djpohly/dwl)** - Lightweight Wayland compositor
- **[nixos-hardware](https://github.com/NixOS/nixos-hardware)** - GPD Pocket 3 hardware profile
- **[home-manager](https://github.com/nix-community/home-manager)** - Declarative user environment

---

## 💬 Support & Community

- **Issues**: [GitHub Issues](https://github.com/0x64616e61/NaN/issues)
- **Discussions**: [GitHub Discussions](https://github.com/0x64616e61/NaN/discussions)
- **NixOS Help**: [NixOS Discourse](https://discourse.nixos.org/)
- **GPD Hardware**: [nixos-hardware GPD Pocket 3](https://github.com/NixOS/nixos-hardware/tree/master/gpd/pocket-3)

---

<div align="center">

**NaN** - Minimal, secure, and performant NixOS for GPD Pocket 3

Made with ❤️ using [NixOS](https://nixos.org/)

</div>
