# NaN - Standalone Deployment Guide

This NixOS configuration is now **portable and standalone** - you can deploy it on any system by customizing a single file.

## Quick Start

### 1. Clone this repository

```bash
git clone https://github.com/0x64616e61/NaN.git /tmp/NaN
cd /tmp/NaN
```

### 2. Customize for your system

Edit `config-variables.nix`:

```nix
{
  # Primary user configuration
  user = {
    name = "yourname";  # YOUR username
    description = "Your Full Name";
    homeDirectory = "/home/yourname";  # Auto-derived if omitted
  };

  # System identification
  hostname = "YourHostname";

  # Hardware profile
  # Options: "gpd-pocket-3" | "generic" | null
  hardwareProfile = "gpd-pocket-3";  # Set to null for generic systems
}
```

### 3. Generate hardware configuration

```bash
sudo nixos-generate-config --show-hardware-config > /tmp/NaN/hardware-configuration.nix
```

Note: The repo includes `hardware-config.nix` which will automatically use `/etc/nixos/hardware-configuration.nix` if it exists, or fall back to the included `hardware-configuration-fallback.nix`.

### 4. Deploy

#### Option A: Install to /etc/nixos

```bash
sudo cp -r /tmp/NaN/* /etc/nixos/
cd /etc/nixos
sudo nixos-rebuild switch --flake .#YourHostname
```

#### Option B: Build from external directory

```bash
cd /tmp/NaN
sudo nixos-rebuild switch --flake .#YourHostname --impure
```

### 5. Set user password

```bash
sudo passwd yourname
```

## Configuration Variables

### User Configuration

```nix
user = {
  name = "a";              # System username
  description = "a";       # Full name/description
  homeDirectory = "/home/a";  # Home directory (optional, auto-derived from name)
};
```

### Hostname

```nix
hostname = "NaN";  # System hostname (used in flake outputs)
```

### Hardware Profile

```nix
hardwareProfile = "gpd-pocket-3";  # Options:
# - "gpd-pocket-3": Enables GPD Pocket 3 specific modules (display rotation, etc.)
# - null: Generic system (no special hardware modules)
```

## Supported Hardware Profiles

### GPD Pocket 3

Enables:
- Portrait display rotation (1200x1920 @ 270°)
- Touchscreen optimization  
- Focaltech fingerprint reader
- Thermal management for Intel mobile CPUs
- GRUB with portrait resolution

### Generic Systems

Set `hardwareProfile = null` in `config-variables.nix` to disable GPD-specific modules.

## Build Commands

After customizing `config-variables.nix`, use these commands:

```bash
# Replace "NaN" with your hostname from config-variables.nix

# Test without activating
sudo nixos-rebuild build --flake .#YourHostname

# Activate without creating boot entry
sudo nixos-rebuild test --flake .#YourHostname

# Full rebuild with boot entry (recommended)
sudo nixos-rebuild switch --flake .#YourHostname

# Build for next boot only
sudo nixos-rebuild boot --flake .#YourHostname
```

## What Gets Configured

- **User**: Parameterized from `config-variables.nix`
- **Home Manager**: Automatically configured for the specified user
- **DWL**: Wayland compositor with status bar
- **Security**: AppArmor, fingerprint authentication (if hardware present)
- **Display Manager**: SDDM with X11/Wayland support
- **Shell**: Zsh with configuration
- **Hardware**: GPD Pocket 3 optimizations (if enabled)

## Advanced Customization

### Locale and Timezone

Edit `configuration.nix`:

```nix
time.timeZone = "America/New_York";  # Change timezone
i18n.defaultLocale = "en_US.UTF-8";  # Change locale
```

### Additional Users

Edit `configuration.nix` to add more users:

```nix
users.users.seconduser = {
  isNormalUser = true;
  extraGroups = [ "wheel" "networkmanager" ];
  # ...
};
```

### Enable Optional Modules

Edit `modules/system/default.nix` to enable features:

```nix
custom.system.backup.enable = true;  # Enable automated backups
custom.system.security.hardening.restrictSSH = true;  # Harden SSH
```

## Rollback

If something breaks, reboot and select a previous generation in GRUB:

1. Reboot system
2. In GRUB menu, select "NixOS - Configuration X" (older generation)
3. Once booted, optionally rollback: `sudo nixos-rebuild --rollback`

## Repository Structure

```
/etc/nixos/
├── config-variables.nix      ← CUSTOMIZE THIS FILE
├── flake.nix                  # Flake with parameterized user
├── configuration.nix          # Main config (reads config-variables.nix)
├── hardware-config.nix        # Dynamic hardware wrapper
├── hardware-configuration-fallback.nix  # Generic fallback
├── modules/
│   ├── system/                # System-level modules
│   └── hm/                    # Home Manager modules
└── DEPLOYMENT.md              # This file
```

## Troubleshooting

### Error: "attribute 'name' missing"

Your `config-variables.nix` is incomplete. Ensure it has all required fields:

```nix
{
  user = { name = "..."; description = "..."; };
  hostname = "...";
  hardwareProfile = "gpd-pocket-3";  # or null
}
```

### Build fails with hardware errors

Set `hardwareProfile = null` in `config-variables.nix` to disable hardware-specific modules.

### User doesn't exist after rebuild

The username in `config-variables.nix` must match throughout. Rebuild with:

```bash
sudo nixos-rebuild switch --flake .#YourHostname
```

Then set password:

```bash
sudo passwd yourusername
```

## Next Steps

1. **Backup**: Enable automated backups in `modules/system/default.nix`
2. **Secrets**: Set up password management (KeePassXC configured)
3. **Home Manager**: Customize DWL, applications in `modules/hm/`
4. **Git**: Configure git with your credentials

## Support

For issues specific to this configuration:
- Check `README.md` for module documentation
- Review `MODULE_API.md` for all configuration options
- See `ARCHITECTURE.md` for system design

For NixOS general help:
- https://nixos.org/manual/
- https://nixos.wiki/
