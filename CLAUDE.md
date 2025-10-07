# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Personal NixOS configuration for GPD Pocket 3 handheld PC using Hydenix (Hyprland-based desktop). Features hardware-specific optimizations for touchscreen gestures, fingerprint authentication, auto-rotation, and thermal management. Modular structure with 61+ modules split between system-level and user-level (Home Manager) configurations.

## Critical Context

- **Repository**: Current directory `/home/a/NaN` (local working directory)
- **Flake Name**: `NaN` (primary)
- **Module Namespaces**:
  - `hydenix.*` - Core Hydenix framework options
  - `custom.system.*` - System-level modules (requires sudo)
  - `custom.hm.*` - User-level Home Manager modules
- **Configuration Flow**: `flake.nix` → `configuration.nix` → `modules/system/` & `modules/hm/`
- **Hardware Detection**: Smart wrapper in `hardware-config.nix` with `--impure` flag required
- **Window Manager**: DWL (Wayland compositor), not Hyprland

## Essential Commands

### System Rebuilds
```bash
# Quick update (commit + push + rebuild) - RECOMMENDED
update!

# Standard rebuild - ALWAYS use --impure flag for hardware detection
sudo nixos-rebuild switch --flake .#NaN --impure

# Test without switching (safe - no activation)
sudo nixos-rebuild test --flake .#NaN --impure

# Build only (compare before switching)
rebuild-diff  # Builds and shows nvd diff

# Dry-run (see what would change)
rebuild-dry

# Emergency rollback
panic  # or: A!, AA!, AAA!, AAAA!, AAAAA!
sudo nixos-rebuild switch --rollback
```

### Development & Testing
```bash
# Validate configuration
nix flake check

# Build and compare with current system
nixos-rebuild build --flake .#NaN --impure && nvd diff /run/current-system result

# Update flake inputs
nix flake update          # All inputs
nix flake update hydenix  # Specific input

# Work summary (analyze last 12h of commits)
worksummary
```

### Hardware Diagnostics
```bash
# Touchscreen (GPD Pocket 3)
sudo libinput debug-events --device /dev/input/event18

# Display
wlr-randr                 # Display setup (expect DSI-1)

# Services & errors
journalctl -xe --user     # User services
journalctl -b -p err      # Boot errors

# Thermal monitoring
sensors                   # CPU temperature
journalctl -u thermal-monitor -f
```

## Architecture

### High-Level Structure

```
/home/a/NaN/                   # Local working directory
├── flake.nix                  # Flake entrypoint (inputs: hydenix, nixpkgs, nix-index-database, grub2-themes, sops-nix)
├── flake.lock                 # Pinned dependency versions
├── configuration.nix          # Main system config (imports modules)
├── hardware-config.nix        # Smart wrapper for hardware detection (requires --impure)
├── modules/
│   ├── system/default.nix     # System module configuration (custom.system.* options)
│   └── hm/default.nix         # User module configuration (custom.hm.* options)
└── docs/                      # Documentation (start with NAVIGATION.md)
```

**Key Insight:** This is a **declarative configuration**, not application code. You're working with:
- Nix expressions that define system behavior
- Modules that are enabled/disabled via options
- Two namespaces: `custom.system.*` (system-wide) and `custom.hm.*` (user-level)

### Module Structure
```
modules/
├── system/              # custom.system.* namespace
│   ├── hardware/        # GPD-specific: fingerprint, rotation, thermal
│   │   ├── focal-spi/   # FTE3600 fingerprint (kernel module + libfprint patch)
│   │   ├── thermal-management.nix
│   │   ├── auto-rotate.nix
│   │   └── acpi-fixes.nix
│   ├── power/           # Battery, lid behavior, suspend control
│   ├── security/        # Fingerprint auth, secrets management, hardening
│   ├── packages/        # Custom derivations (SuperClaude, MCP servers)
│   │   └── mcp/         # 6 MCP server modules (context7, magic, playwright, etc.)
│   ├── input/           # Keyboard (keyd), mouse (vial)
│   ├── network/         # iPhone USB tethering
│   └── *.nix           # Boot, monitor, display, dwl-custom, auto-commit, update-alias
└── hm/                  # custom.hm.* namespace (Home Manager)
    ├── applications/    # Firefox, Ghostty, MPV, btop
    ├── audio/           # EasyEffects, MPD
    ├── desktop/         # Idle, rotation, theming, animations
    ├── dwl/             # DWL window manager configuration
    └── claude-code*     # Claude Code integration modules
```

### Key Files
- `flake.nix` - Inputs: hydenix, nixpkgs, nix-index-database, grub2-themes, sops-nix
- `configuration.nix` - Main config (user: a, host: NaN, timezone, locale)
- `hardware-config.nix` - Smart wrapper for `/etc/nixos/hardware-configuration.nix`
- `modules/system/default.nix` - System module toggles
- `modules/hm/default.nix` - User module toggles
- `modules/system/update-alias.nix` - Defines `update!`, `panic`, `worksummary` commands
- `modules/system/dwl-custom.nix` - DWL compositor configuration
- `modules/system/dwl-keybinds.nix` - DWL keybinding definitions

### Active System
- **Hardware**: GPD Pocket 3 (Intel i3-1125G4)
- **Display**: DSI-1, 1200x1920@60Hz, 1.5x scale, 270° rotation
- **Shell**: zsh with oh-my-posh prompt
- **Terminal**: Ghostty (0.85 opacity, pure black background)
- **Desktop**: DWL (Wayland compositor) with custom status bar
- **Theme**: Pure black + Catppuccin Mocha accents

## GPD Pocket 3 Hardware

### Display & Touch
- **Display**: DSI-1, 1200x1920@60Hz, 1.5× scale, 270° rotation
- **Touchscreen**: `/dev/input/event18` (GXTP7380:00 27C6:0113)
- **Auto-Rotation**: Accelerometer via `/sys/bus/iio/devices/iio:device0`
- **Multi-Monitor**: DP-1, HDMI-A-1 with independent orientation
- **Module**: `modules/system/monitor-config.nix`, `modules/hm/desktop/auto-rotate-service.nix`

### Authentication & Security
- **Fingerprint**: FocalTech FTE3600 SPI scanner at `/dev/focal_moh_spi`
- **PAM Integration**: SDDM, sudo, swaylock
- **Custom Module**: `modules/system/hardware/focal-spi/` (kernel module + patched libfprint)
- **Test**: `fprintd-enroll` to add fingerprint

### Touchscreen
- **Device**: GXTP7380:00 27C6:0113 at `/dev/input/event18`
- **Module**: `modules/system/touchscreen-pen.nix`

### Thermal Management
- **CPU**: Intel i3-1125G4 (4C/8T, 2.0-3.3GHz)
- **Thresholds**: Throttle 80°C, Critical 90°C, Emergency 95°C
- **Waybar**: Real-time temp display (T:XX°) from `thermal_zone5`
- **Services**: thermald + thermal-monitor
- **Module**: `modules/system/hardware/thermal-management.nix`

### Power
- **Lid Behavior**: Ignore (no suspend on close)
- **TLP**: Disabled (conflicts with power-profiles-daemon)
- **Commands**: `power-profile performance|powersave`, `battery-status`

## Development Workflow

### Making Changes

**Standard workflow:**
1. Edit module file (use `sudo` for `/nix-modules/` files)
2. **Test first** (safe, no activation): `rebuild-test`
3. If successful, apply: `update!` (commits + pushes + rebuilds)
4. Auto-commit in `modules/system/auto-commit.nix` handles git operations
5. If broken: `panic` (rollback to GitHub) or `sudo nixos-rebuild switch --rollback`

**Common tasks:**

```bash
# Enable an existing module
# Edit modules/system/default.nix or modules/hm/default.nix
custom.system.hardware.thermal.enable = true;

# Check what would change before applying
rebuild-diff

# View recent changes
worksummary  # AI-generated summary of last 12h commits

# Validate configuration syntax
nix flake check
```

### Adding Modules

**Creating a new module:**

1. **Create module file:**
   ```bash
   # System-level module
   sudo vim modules/system/myfeature.nix

   # User-level module
   sudo vim modules/hm/myfeature.nix
   ```

2. **Define module structure:**
   ```nix
   { config, lib, pkgs, ... }:

   with lib;

   let
     cfg = config.custom.system.myfeature;  # or custom.hm.myfeature
   in {
     options.custom.system.myfeature = {
       enable = mkEnableOption "My Feature";
       someOption = mkOption {
         type = types.str;
         default = "value";
         description = "Description of option";
       };
     };

     config = mkIf cfg.enable {
       # Your configuration here
       environment.systemPackages = [ pkgs.somepackage ];
     };
   }
   ```

3. **Import in parent `default.nix`:**
   ```nix
   # In modules/system/default.nix or modules/hm/default.nix
   imports = [
     ./myfeature.nix
     # ... other imports
   ];
   ```

4. **Enable in configuration:**
   ```nix
   # In modules/system/default.nix (for system modules)
   # or modules/hm/default.nix (for user modules)
   custom.system.myfeature = {
     enable = true;
     someOption = "custom value";
   };
   ```

5. **Test and apply:**
   ```bash
   rebuild-test  # Test without activation
   update!       # Apply and commit
   ```

### Package Management
- **System packages**: `environment.systemPackages` in `modules/system/default.nix`
- **User packages**: `home.packages` in `modules/hm/default.nix`
- **Custom derivations**: Create in `modules/system/packages/` (see `superclaude.nix`)

## Important Implementation Details

### Hardware Detection (CRITICAL)
**The `--impure` flag is NON-NEGOTIABLE for all rebuilds.**

- `hardware-config.nix` is a smart wrapper that:
  - Uses `/etc/nixos/hardware-configuration.nix` when available (local system)
  - Falls back to placeholder for GitHub sync compatibility
  - Requires `--impure` flag to access files outside Nix store
- **Without `--impure`**: Build fails with "getting status of '/etc/nixos/hardware-configuration.nix': No such file"
- All rebuild aliases (`update!`, `rebuild-test`, etc.) include `--impure` automatically

### Auto-commit System
How `update!` works:

1. **Pre-flight check** (`modules/system/auto-commit.nix`):
   - Checks `git status --porcelain` for uncommitted changes
   - If changes exist: commits with timestamp, pushes to GitHub via `gh` CLI
   - Handles push failures gracefully (shows troubleshooting steps)

2. **Rebuild**:
   - Runs `nixos-rebuild switch --flake .#NaN --impure`
   - Shows errors if rebuild fails
   - Suggests rollback commands

3. **Authentication**:
   - Uses `gh` CLI for GitHub operations (not raw git)
   - Polkit handles privilege escalation (no hardcoded passwords)
   - Check auth status: `gh auth status`

**Disable auto-commit:** Remove import in `configuration.nix:31`

### Module Patterns

**Two namespaces control all configuration:**

```nix
# System-wide (requires sudo, affects all users)
custom.system.hardware.thermal = {
  enable = true;
  throttleTemp = 80;
};

# User-level (Home Manager, per-user settings)
custom.hm.applications.firefox = {
  enable = true;
  enableCascade = true;
};
```

**Common pattern in modules:**
```nix
let
  cfg = config.custom.system.myfeature;
in {
  options.custom.system.myfeature = { ... };
  config = mkIf cfg.enable { ... };  # Only applies if enabled
}
```

### Key File Locations
- `configuration.nix:82-105` - User account, hostname, timezone, locale
- `modules/system/default.nix:23-227` - System module toggles and configuration
- `modules/hm/default.nix:15-151` - User module toggles and configuration
- `modules/system/update-alias.nix` - Shell aliases: `update!`, `panic`, `worksummary`, `help-aliases`
- `modules/system/auto-commit.nix` - Git automation (systemd service + polkit rules)

## Best Practices

### DO
- ✅ **Always use `--impure` flag** with nixos-rebuild (or use aliases: `update!`, `rebuild-test`)
- ✅ **Test before switching**: `rebuild-test` → verify → `update!` for safe changes
- ✅ **Use proper namespaces**: `custom.system.*` (system-wide) or `custom.hm.*` (user-level)
- ✅ **Check logs** when services fail:
  - User services: `journalctl -xe --user`
  - System services: `journalctl -xe`
  - Boot errors: `journalctl -b -p err`
- ✅ **Use `sudo`** for all `/nix-modules/` file modifications (system-wide location)
- ✅ **Leverage helper commands**: `help-aliases` to see all available commands
- ✅ **Validate before rebuild**: `nix flake check` to catch syntax errors

### DON'T
- ❌ **Never rebuild without `--impure`** (breaks hardware detection, build will fail)
- ❌ **Don't commit secrets** (Nix store is world-readable at `/nix/store/`)
- ❌ **Don't modify `/etc/nixos/hardware-configuration.nix`** directly (use `hardware-config.nix` wrapper)
- ❌ **Don't skip module imports** in `default.nix` files (module won't be loaded)
- ❌ **Don't enable multiple rotation modules** simultaneously (causes conflicts)
- ❌ **Don't edit files in `~/.config/hypr/`** directly (managed by Home Manager, changes will be overwritten)

## Emergency Recovery

```bash
# Reset to GitHub state (creates backup branch)
panic  # or: A!, AA!, AAA!, AAAA!, AAAAA!

# Rollback to previous generation
sudo nixos-rebuild switch --rollback

# Check system errors
journalctl -b -p err
```

## Common Workflows & Examples

### Enabling a Feature
```bash
# Example: Enable thermal monitoring
sudo vim modules/system/default.nix

# Add or modify:
custom.system.hardware.thermal = {
  enable = true;
  throttleTemp = 80;
};

# Test and apply
rebuild-test && update!
```

### Troubleshooting a Service
```bash
# Check if service is running
systemctl --user status auto-rotate-both  # User service
systemctl status thermald                  # System service

# View logs
journalctl --user -u auto-rotate-both -n 50
journalctl -u thermald -n 50

# Restart service
systemctl --user restart auto-rotate-both
sudo systemctl restart thermald
```

### Updating Inputs
```bash
cd /nix-modules

# Update all flake inputs
nix flake update

# Update specific input
nix flake update hydenix
nix flake update nixpkgs

# Apply updates
update!
```

### Finding Configuration Options
```bash
# Search in module source
grep -r "mkOption" modules/system/hardware/thermal-management.nix

# Check documentation
cat docs/options.md | grep -A 5 "thermal"

# Query active system (if option exists)
nixos-option custom.system.hardware.thermal.enable
```

## Documentation

- **Start Here**: `docs/NAVIGATION.md` - Documentation hub with guided paths
- **Quick Fixes**: `docs/troubleshooting-checklist.md` - 5-minute diagnostic steps
- **Options Reference**: `docs/options.md` - All 219+ configuration options
- **Architecture**: `docs/architecture.md` - System design and module interactions
- **Installation**: `docs/installation.md` - Fresh install guide
- **Migration**: `docs/migration.md` - Migrating from existing NixOS
- **SuperClaude Framework**: `.claude/RULES.md` - AI-assisted development patterns