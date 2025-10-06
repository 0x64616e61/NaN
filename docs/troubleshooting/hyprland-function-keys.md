# Hyprland Function Keys Fix

**Date**: 2025-10-06
**System**: GPD Pocket 3, NixOS with Hyprland
**Status**: ✅ RESOLVED

## Problem

Function keys (Fn+F1-F12) not working in Hyprland:
- Volume controls (XF86AudioRaiseVolume, XF86AudioLowerVolume, XF86AudioMute)
- Brightness controls (XF86MonBrightnessUp, XF86MonBrightnessDown)
- Media controls (XF86AudioPlay, XF86AudioPause, XF86AudioNext, XF86AudioPrev)

## Root Cause

Function keys were defined using `bind` instead of `bindl` in Hyprland configuration.

**Key Difference:**
- `bind` = Regular keybind (can be inhibited by focused applications)
- `bindl` = Lock-screen bind (always works, even when screen locked or app has focus)

System-level keys like volume and brightness **must** use `bindl` to work consistently.

## Solution

### 1. Locate Source Configuration

Hyprland config is managed by Home Manager in NixOS:
```bash
# Read-only symlink (don't edit this)
~/.config/hypr/hyprland.conf -> /nix/store/...-hm_hyprhyprland.conf

# Source file (edit this)
/home/a/nix-modules/modules/hm/hyprland/default.nix
```

### 2. Change Bind Type

**Before** (lines 150-163):
```nix
bind = [
  # Function keys for GPD Pocket 3
  # Volume controls
  ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
  ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
  # ... more function keys
];
```

**After** (lines 193-210):
```nix
# Function keys (bindl = works even when locked/inhibited)
bindl = [
  # Volume controls
  ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
  ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
  ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
  ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"

  # Brightness controls
  ", XF86MonBrightnessUp, exec, brightnessctl set 10%+"
  ", XF86MonBrightnessDown, exec, brightnessctl set 10%-"

  # Media controls
  ", XF86AudioPlay, exec, playerctl play-pause"
  ", XF86AudioPause, exec, playerctl play-pause"
  ", XF86AudioNext, exec, playerctl next"
  ", XF86AudioPrev, exec, playerctl previous"
];
```

### 3. Rebuild System

```bash
cd /home/a/nix-modules

# Method 1: Using update! alias (commits + rebuilds)
update!

# Method 2: Manual rebuild
sudo nixos-rebuild switch --flake . --impure
```

### 4. Verify Fix

```bash
# Check that function keys are registered as bindl
hyprctl binds | grep XF86

# Expected output:
# bindl
# 	key: XF86AudioRaiseVolume
# bindl
# 	key: XF86AudioLowerVolume
# ... (10 function keys total)
```

## Additional Fixes Required

During troubleshooting, these issues were also resolved:

### Hostname Alias Missing

**Problem**: Flake didn't have `grOSs` hostname configured
**Fix**: Added to `/home/a/nix-modules/flake.nix:55`
```nix
nixosConfigurations.grOSs = hydenixConfig; # Current system hostname
```

### Broken Imports

**Problem**: Configuration referenced missing files
**Fix**: Commented out in `/home/a/nix-modules/configuration.nix:33-34`
```nix
# ./.claude/cleanup-automation.nix # (disabled - file missing)
# ./.claude/disk-space-monitor.nix # (disabled - file missing)
```

### Duplicate Keybind

**Problem**: SUPER+A bound twice (lines 73 and 83 in generated config)
**Fix**: Consolidated to single definition in source Nix file

## Hyprland Bind Types Reference

```nix
bind   = Regular keybind (can be inhibited by applications)
bindl  = Lock-screen bind (works even when locked/inhibited)
binde  = Repeating bind (triggers on hold)
bindel = Repeating lock-screen bind
bindm  = Mouse binding (for drag operations)
```

**When to use `bindl`:**
- Volume controls
- Brightness controls
- Media playback controls
- Screen lock/unlock
- Any system-level key that should always work

**When to use `bind`:**
- Application launchers
- Window management (move, resize, focus)
- Workspace switching
- Most keyboard shortcuts

## Testing Procedure

After rebuild, test all function keys:

| Key Combo | Function | Expected Result |
|-----------|----------|-----------------|
| Fn+F1 | Brightness Down | Screen dims |
| Fn+F2 | Brightness Up | Screen brightens |
| Fn+F5 | Previous Track | Media player goes to previous |
| Fn+F6 | Play/Pause | Media toggles play/pause |
| Fn+F7 | Stop | Media stops |
| Fn+F8 | Next Track | Media player advances |
| Fn+F10 | Mute Audio | Volume mutes/unmutes |
| Fn+F11 | Volume Down | Volume decreases |
| Fn+F12 | Volume Up | Volume increases |

## Related Issues

### hyprctl Communication

If `hyprctl` commands fail with "Error":
```bash
# Check socket location
ls /tmp/hypr/         # Expected location
ls /run/user/1000/hypr/  # Actual location (on some systems)

# Create symlink workaround
ln -sf /run/user/1000/hypr /tmp/hypr

# Verify
hyprctl binds | head
```

### Shell Keybind Issues

This was a **Hyprland** keybind issue, not shell keybinds. For shell keybind problems (zsh/bash), see separate documentation.

## Prevention

**Best Practices:**
1. Always use `bindl` for system-level function keys
2. Test keybinds after Hyprland config changes: `hyprctl binds | grep XF86`
3. Edit source Nix files, never the generated config symlinks
4. Use `--impure` flag for all NixOS rebuilds

**Configuration Management:**
- Source: `/home/a/nix-modules/modules/hm/hyprland/default.nix`
- Generated: `~/.config/hypr/hyprland.conf` (read-only symlink)
- Verify changes: `hyprctl binds`

## References

- [Hyprland Keybind Documentation](https://wiki.hyprland.org/Configuring/Binds/)
- [Home Manager Hyprland Module](https://nix-community.github.io/home-manager/options.xhtml#opt-wayland.windowManager.hyprland.settings)
- GPD Pocket 3 keyboard layout: Fn keys are F1-F12 with hardware function overlay

## Session Analysis

**Initial Misdiagnosis**: Started analyzing shell keybinds (.bashrc, .zshrc) before user clarified issue was Hyprland-specific.

**Shell Config Issues Found** (separate from main issue):
- .bashrc: Missing shebang, hardcoded paths, duplicate aliases, sources missing file
- .zshrc: oh-my-posh eval may overwrite keybinds, command_not_found_handler security risk
- Both: Excessive nix-shell per-command overhead (200-500ms)

See `/docs/troubleshooting/shell-config-analysis.md` for shell-specific issues.
