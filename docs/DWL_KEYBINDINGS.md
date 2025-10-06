# DWL Keybindings Reference - grOSs

**Compositor:** DWL (dwm for Wayland)
**Modifier Key:** SUPER (Windows/Logo key)
**Configuration:** `modules/system/dwl-custom.nix`

## Overview

grOSs uses DWL, a minimal tiling Wayland compositor based on the dwm window manager philosophy. All keybindings use the **SUPER key** (Windows/Command key) as the modifier, customized from the default ALT key for better ergonomics on the GPD Pocket 3.

## Window Navigation

### Focus Control
| Keybind | Action | Description |
|---------|--------|-------------|
| `SUPER + j` | Focus Next | Move focus to next window in stack (downward) |
| `SUPER + k` | Focus Previous | Move focus to previous window in stack (upward) |
| `SUPER + Return` | Zoom | Swap focused window with master (promote to main area) |
| `SUPER + Tab` | Previous Tag | Toggle back to previously viewed workspace |

### Window Manipulation
| Keybind | Action | Description |
|---------|--------|-------------|
| `SUPER + Shift + C` | Kill Window | Close the currently focused window |
| `SUPER + e` | Fullscreen | Toggle fullscreen mode for focused window |
| `SUPER + Shift + Space` | Toggle Float | Make window floating or return to tiling |

### Master Area Control
| Keybind | Action | Description |
|---------|--------|-------------|
| `SUPER + h` | Shrink Master | Decrease master area width by 5% |
| `SUPER + l` | Expand Master | Increase master area width by 5% |
| `SUPER + i` | More Masters | Increase number of windows in master area |
| `SUPER + d` | Fewer Masters | Decrease number of windows in master area |

## Layout Management

### Layout Selection
| Keybind | Action | Description |
|---------|--------|-------------|
| `SUPER + t` | Tile Layout | Default tiling layout (master + stack) |
| `SUPER + f` | Floating Layout | All windows floating (manual positioning) |
| `SUPER + m` | Monocle Layout | Fullscreen each window, one at a time |
| `SUPER + Space` | Cycle Layouts | Switch between tile/float/monocle |

**Layout Behavior:**
- **Tile**: One or more master windows on left, stack on right
- **Floating**: Windows can be freely moved and resized
- **Monocle**: Full screen, switch between windows with j/k

## Workspace Management (Tags)

### Tag Navigation
| Keybind | Action | Description |
|---------|--------|-------------|
| `SUPER + 1-9` | View Tag | Switch to workspace/tag 1-9 |
| `SUPER + 0` | View All | Show all tags simultaneously |
| `SUPER + Tab` | Previous | Toggle to last viewed tag |

### Window Tagging
| Keybind | Action | Description |
|---------|--------|-------------|
| `SUPER + Shift + 1-9` | Move to Tag | Send window to workspace 1-9 |
| `SUPER + Shift + 0` | Tag All | Make window visible on all tags |

**Tag Concepts:**
- Tags are like workspaces but more flexible
- Windows can belong to multiple tags
- View multiple tags simultaneously with `SUPER + 0`

## Application Launching

| Keybind | Action | Description |
|---------|--------|-------------|
| `SUPER + Shift + Return` | Terminal | Launch Ghostty terminal |
| `SUPER + p` | Menu | Open application launcher (dmenu/bemenu) |

**Configured Applications:**
- **Terminal**: Ghostty (customized from default foot)
- **Launcher**: bemenu (Wayland-native)

## Multi-Monitor Support

### Monitor Focus
| Keybind | Action | Description |
|---------|--------|-------------|
| `SUPER + ,` | Focus Left | Move focus to left monitor |
| `SUPER + .` | Focus Right | Move focus to right monitor |

### Window Movement
| Keybind | Action | Description |
|---------|--------|-------------|
| `SUPER + Shift + <` | Send Left | Move window to left monitor |
| `SUPER + Shift + >` | Send Right | Move window to right monitor |

## Mouse Controls

| Mouse Action | Function | Description |
|--------------|----------|-------------|
| `SUPER + Left Click & Drag` | Move Window | Drag floating windows |
| `SUPER + Right Click & Drag` | Resize Window | Resize floating windows |
| `SUPER + Middle Click` | Toggle Float | Make window floating/tiling |

**Tips:**
- Works on any part of the window
- Extremely useful for touchscreen on GPD Pocket 3
- No need to grab title bars

## System Controls

### Session Management
| Keybind | Action | Description |
|---------|--------|-------------|
| `SUPER + Shift + Q` | Quit DWL | Logout (returns to SDDM) |
| `Ctrl + Alt + Backspace` | Emergency Quit | Force quit compositor |

### Virtual Terminal Switching
| Keybind | Action | Description |
|---------|--------|-------------|
| `Ctrl + Alt + F1-F12` | Switch VT | Change to virtual terminal 1-12 |

**VT Usage:**
- VT1: SDDM login (graphical)
- VT2-6: Available for additional sessions
- VT7+: Additional graphical sessions

## Screen Locking

The system automatically locks the screen using swaylock:

### Automatic Lock Events
- **Idle timeout**: 120 seconds (2 minutes)
- **Before suspend**: Locks before entering sleep
- **Before shutdown**: Locks before system shutdown/restart
- **Manual lock**: `loginctl lock-session`

### Lock Screen Features
- Fingerprint authentication (via fprintd)
- Password fallback
- Shows time and date
- Integrated with systemd-logind

## Touchscreen Gestures

DWL supports basic touchscreen input on the GPD Pocket 3:

- **Tap**: Focus window
- **Drag**: Move floating windows
- **SUPER + Tap & Drag**: Move any window
- **Swipe**: Scroll within applications

Additional gestures configured via `libinput-gestures` (see `modules/hm/desktop/gestures.nix`)

## Customization

### Modifying Keybindings

Keybindings are configured via NixOS overlay in `modules/system/dwl-custom.nix`:

```nix
nixpkgs.overlays = [
  (final: prev: {
    dwl = prev.dwl.overrideAttrs (old: {
      postPatch = (old.postPatch or "") + ''
        # Change MODKEY
        sed -i 's/#define MODKEY WLR_MODIFIER_ALT/#define MODKEY WLR_MODIFIER_LOGO/' config.def.h

        # Add custom keybindings
        sed -i '/static const Key keys/a \
          { MODKEY, XKB_KEY_w, spawn, {.v = (const char*[]){ "firefox", NULL }} },
        ' config.def.h
      '';
    });
  })
];
```

**Steps to customize:**

1. Edit `modules/system/dwl-custom.nix`
2. Add sed commands to modify `config.def.h`
3. Rebuild: `sudo nixos-rebuild switch --flake .#grOSs`
4. Logout and login to activate

### Available Modifiers
- `MODKEY` - SUPER (Logo key)
- `WLR_MODIFIER_SHIFT` - Shift key
- `WLR_MODIFIER_CTRL` - Control key
- `WLR_MODIFIER_ALT` - Alt key
- Combine with `|` (e.g., `MODKEY|WLR_MODIFIER_SHIFT`)

### Common Functions
- `spawn` - Launch application
- `focusstack` - Change window focus
- `setmfact` - Adjust master area size
- `killclient` - Close window
- `quit` - Exit compositor

## Troubleshooting

### Keybinding Not Working

1. **Check key availability:**
   ```bash
   # Test if DWL receives key events
   wev  # Wayland event viewer
   ```

2. **Verify configuration:**
   ```bash
   # Check if custom overlay applied
   nix eval --raw .#nixosConfigurations.grOSs.config.nixpkgs.overlays
   ```

3. **Rebuild system:**
   ```bash
   sudo nixos-rebuild switch --flake .#grOSs
   ```

### Conflicts with System Keybindings

Some keybindings might conflict with:
- **keyd** keyboard remapping (`modules/system/input/keyd.nix`)
- **System shortcuts** (VT switching, etc.)

Priority order:
1. keyd remapping (lowest level)
2. DWL compositor bindings
3. Application-specific bindings

## Quick Reference Card

### Most Common Actions
```
Launch Terminal:     SUPER + Shift + Return
Launch Menu:         SUPER + p
Kill Window:         SUPER + Shift + C
Switch Workspace:    SUPER + [1-9]
Move Window:         SUPER + Shift + [1-9]
Focus Next:          SUPER + j
Focus Previous:      SUPER + k
Fullscreen:          SUPER + e
Logout:              SUPER + Shift + Q
```

### Layouts at a Glance
```
[SUPER + t] Tile     [SUPER + f] Float     [SUPER + m] Monocle
┌─────┬───┐          ┌─────────┐          ┌─────────┐
│     │ 2 │          │  ┌──┐   │          │         │
│  1  ├───┤          │  │2 │   │          │    1    │
│     │ 3 │          │  └──┘ ┌┐│          │         │
└─────┴───┘          └───────┘││          └─────────┘
                              └┘
```

## See Also

- **DWL Homepage**: https://codeberg.org/dwl/dwl
- **grOSs Configuration**: `modules/system/dwl-custom.nix`
- **Home Manager DWL**: `modules/hm/dwl/default.nix`
- **Lock Screen Integration**: `docs/LOCK_SCREEN_INTEGRATION.md`
- **GPD Pocket 3 Hardware**: `CLAUDE.md` - GPD Pocket 3 Hardware Specifics

## Version History

- **v1.0** (2025-10-05): Initial documentation with SUPER key configuration
- Compositor: DWL (latest from nixpkgs-unstable)
- NixOS: 25.11 (Xantusia)
