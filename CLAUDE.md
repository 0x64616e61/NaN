# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Personal NixOS configuration for GPD Pocket 3 device using Hydenix (Hyprland-based desktop environment). Features hardware-specific optimizations, touchscreen gestures, fingerprint authentication, and modular system/home configuration.

## Critical Context

- **Repository Location**: `/nix-modules/` (system-wide, requires sudo for modifications)
- **Flake System**: `hydenix` and `mini` (alias) - both nixosConfigurations point to same config
- **Module System**: Three-tier option system with `hydenix.*` (core), `custom.system.*` (system), and `custom.hm.*` (user)
- **Sudo Password**: `7` (for system operations)
- **Total Module Count**: 61 Nix files across system and home-manager modules
- **Configuration Flow**: flake.nix:47-48 → configuration.nix:28-30 → modules/system & modules/hm
- **Hardware Detection**: Smart wrapper in hardware-config.nix:10-13 with impure fallback
- **Follow RULES.md**: Always delegate todos and use parallel operations where possible

## SuperClaude Framework Integration

This repository is enhanced with the SuperClaude framework for advanced Claude Code operations. The framework provides intelligent task management, parallel execution capabilities, and specialized MCP server integration.

### Framework Components

- **Core Framework**: FLAGS.md, PRINCIPLES.md, RULES.md - Behavioral rules and operational patterns
- **Task Management**: TodoWrite tool for complex multi-step NixOS configurations with delegation support
- **MCP Servers**: Specialized tools for different aspects of NixOS development:
  - **Sequential MCP**: For complex system analysis and debugging multi-component issues
  - **Morphllm MCP**: For bulk configuration changes across multiple modules
  - **Context7 MCP**: For official NixOS/Nix documentation and pattern guidance

### SuperClaude Operational Patterns

**Task Delegation for Complex Rebuilds**:
```bash
# Instead of sequential operations, use parallel delegation:
# 1. Create todos for: hardware test, configuration validation, service verification
# 2. Delegate each todo to specialized agents running in parallel
# 3. Cross-validate results across agents for redundancy
```

**NixOS-Specific SuperClaude Usage**:
- **Module Development**: Use TodoWrite for >3 step module creation tasks
- **Hardware Debugging**: Delegate hardware tests to parallel agents (fingerprint, gestures, thermal)
- **System Recovery**: Use agent delegation for comprehensive system diagnosis
- **Configuration Changes**: Break large config changes into parallel validation tasks

### Framework Integration with NixOS Workflows

The framework enhances standard NixOS operations:
- **Rebuild workflows**: Parallel validation and testing phases
- **Module testing**: Delegated hardware verification across multiple agents
- **System diagnosis**: Multi-agent parallel analysis for complex issues
- **Configuration management**: Systematic task tracking for large changes

See `.claude/` directory for complete framework documentation and operational rules.

## Key Commands

### Quick System Management
```bash
# Quick update: commit, push, and rebuild in one command (uses password '7')
update!

# Create work summary commit (last 12 hours of work)
worksummary

# PANIC MODE - discard all local changes and reset to GitHub
panic
# Alternative: A!, AA!, AAA!, etc. (up to 20 A's)

# Standard rebuild (always use --impure for hardware detection)
sudo nixos-rebuild switch --flake .#hydenix --impure
# Alternative using hostname alias:
sudo nixos-rebuild switch --flake .#mini --impure

# Test configuration without switching
sudo nixos-rebuild test --flake .#hydenix --impure

# Build only (no activation)
sudo nixos-rebuild build --flake .#hydenix --impure

# Rollback to previous generation
sudo nixos-rebuild switch --rollback
```

### Flake Management
```bash
# Update all flake inputs
nix flake update

# Update specific input
nix flake update hydenix

# Check flake metadata and outputs
nix flake show
nix flake metadata
nix flake check

# View system generation differences
nixos-rebuild build --flake .#hydenix --impure && nvd diff /run/current-system result
# Or using hostname alias:
nixos-rebuild build --flake .#mini --impure && nvd diff /run/current-system result
```

### Debugging Commands
```bash
# Monitor touchscreen/gesture events (GPD Pocket 3 touchscreen)
sudo libinput debug-events --device /dev/input/event18

# Hyprland diagnostics
hyprctl plugins list        # Check loaded plugins (should show hyprgrass)
hyprctl reload             # Reload configuration
hyprctl monitors           # Check monitor setup (should show DSI-1)

# Service and error checking
journalctl -xe --user      # User service logs
journalctl -b -p err       # Boot errors
systemctl --user status    # User services status

# Manual service starts (if needed)
waybar &                   # Start waybar manually

# Check Nix evaluation errors
nix flake check --show-trace
nix eval .#nixosConfigurations.hydenix.config.system.build.toplevel --show-trace

# Battery and power management
battery-status                  # Show comprehensive battery info and health
power-profile performance       # Switch to performance mode (AC power profile)
power-profile powersave        # Switch to power save mode (battery profile)
tlp-stat -s                    # Show TLP power management status
upower -i /org/freedesktop/UPower/devices/battery_BAT0  # Detailed battery info
```

## Architecture

### Configuration Hierarchy
```
/nix-modules/
├── flake.nix                    # Flake inputs (hydenix, nixpkgs, grub2-themes, nix-index-database)
├── configuration.nix            # Main system config (user: a, host: mini)
├── hardware-config.nix          # Smart hardware detection wrapper
├── RULES.md                     # Claude behavioral rules and guidelines
├── docs/faq.md                  # Hydenix FAQ and troubleshooting
├── droid/configuration.nix      # Android/Nix-on-Droid config
└── modules/
    ├── system/                  # System-level modules (custom.system.*)
    │   ├── hardware/            # GPD Pocket 3 hardware support
    │   │   ├── auto-rotate.nix # Screen rotation service
    │   │   ├── focal-spi/       # FTE3600 fingerprint reader
    │   │   └── default.nix     # Hardware module aggregation
    │   ├── power/               # Power management
    │   │   ├── lid-behavior.nix # Lid close handling (set to ignore)
    │   │   ├── suspend-control.nix
    │   │   ├── battery-optimization.nix # Comprehensive TLP battery management
    │   │   └── default.nix     # Power module aggregation
    │   ├── security/            # Security features
    │   │   ├── fingerprint.nix # fprintd configuration
    │   │   ├── secrets.nix     # KeePassXC integration
    │   │   └── default.nix     # Security module aggregation
    │   ├── packages/            # Custom packages
    │   │   ├── superclaude.nix # SuperClaude AI framework
    │   │   ├── email.nix       # Proton Bridge + Thunderbird
    │   │   └── default.nix     # Package module aggregation
    │   ├── input/               # Input device configuration
    │   ├── wayland-screenshare.nix # Screen sharing support
    │   ├── boot.nix            # Boot configuration
    │   ├── plymouth.nix        # Boot splash
    │   ├── monitor-config.nix  # Display settings
    │   ├── display-management.nix # Display management
    │   ├── grub-theme.nix      # GRUB theming
    │   ├── mpd.nix             # Music Player Daemon
    │   ├── auto-commit.nix     # Auto-commit on rebuild
    │   ├── update-alias.nix    # update!, panic, worksummary commands
    │   └── default.nix         # System module aggregation (61 total modules)
    └── hm/                      # Home Manager modules (custom.hm.*)
        ├── applications/        # User applications
        │   ├── firefox.nix     # Firefox with Cascade theme
        │   ├── ghostty.nix     # Main terminal emulator
        │   ├── mpv.nix         # Video player config
        │   ├── btop.nix        # System monitor
        │   └── default.nix     # Application module aggregation
        ├── audio/               # Audio configuration
        │   ├── easyeffects.nix # Meze_109_Pro preset
        │   └── default.nix     # Audio module aggregation
        └── desktop/             # Desktop environment (12+ modules)
            ├── auto-rotate-service.nix # Dual-monitor rotation
            ├── hypridle.nix    # Idle management
            ├── waybar-rotation-patch.nix # Rotation lock button
            ├── hyprgrass-config.nix # Gesture configuration
            ├── gestures.nix    # Touch gesture handling
            ├── fusuma.nix      # Alternative gesture engine (disabled)
            ├── libinput-gestures.nix # libinput gesture support
            ├── theme.nix       # Desktop theming
            ├── workflows-ghostty.nix # Workflow automation
            ├── hyprland-ghostty.nix # Hyprland terminal integration
            ├── hyde-ghostty.nix # HyDE theme integration
            ├── waybar-fix.nix  # Waybar configuration fixes
            ├── waybar-rotation-lock.nix # Rotation control
            └── default.nix     # Desktop module aggregation
```

### Module Namespaces
- **hydenix.***: Core Hydenix framework options
- **custom.system.***: System-level customizations
- **custom.hm.***: Home Manager (user-level) customizations

### Current Active Configuration
- **User**: `a` (password: `a`, groups: wheel, networkmanager, video, input)
- **Hostname**: `mini`
- **Shell**: `zsh`
- **Terminal**: `ghostty` (default)
- **Display**: DSI-1, 1200x1920@60, 1.5x scale, transform 3 (270° rotation)

## Hardware-Specific Features

### GPD Pocket 3 Hardware Configuration
Optimized for Intel i3-1125G4 (Tiger Lake) handheld PC with comprehensive hardware support.

#### Display & Input
- **Primary Display**: DSI-1, 1200x1920@60Hz, 1.5x scale, transform 3 (270° rotation)
- **Touchscreen**: GXTP7380:00 27C6:0113 on `/dev/input/event18`
- **Auto-Rotation**: Accelerometer-based via `/sys/bus/iio/devices/iio:device0`
- **Multi-Monitor**: Supports DP-1, HDMI-A-1 with independent orientation
- **Touch Transform**: Synchronized with display rotation
- **Configuration**: `modules/system/monitor-config.nix`

#### Fingerprint Authentication (FTE3600)
- **Reader**: FocalTech FTE3600 SPI scanner
- **Kernel Module**: Custom `focal_spi` module
- **Library**: Patched libfprint with FocalTech support
- **PAM Integration**: SDDM login, sudo, swaylock authentication
- **Device**: `/dev/focal_moh_spi`
- **Configuration**: `modules/system/hardware/focal-spi/`

#### Gesture Support (Hyprgrass)
- **Plugin**: hyprgrass for Hyprland touchscreen gestures
- **Sensitivity**: 4.0 (optimized for touchscreen)
- **Working Gestures**: 3-finger horizontal swipe for workspace switching
- **Bindings**: 3-finger left/right (workspaces), up/down (fullscreen toggle)
- **Configuration**: `modules/hm/desktop/hyprgrass-config.nix`

#### Power & Thermal Management
- **CPU**: Intel i3-1125G4 (4C/8T, 2.0-3.3GHz)
- **Lid Behavior**: Set to "ignore" (prevents unwanted suspend)
- **Thermald**: Enabled for critical thermal protection
- **Temperature Monitoring**: `/sys/class/thermal/thermal_zone0/temp`
- **Battery Optimization**: TLP available but disabled (conflicts with power-profiles-daemon)
- **Configuration**: `modules/system/power/`

### Working Features Status

#### ✅ Fully Functional
- **Display**: DSI-1 with auto-rotation service
- **Touch**: 3-finger horizontal swipe for workspace switching
- **Fingerprint**: SDDM login, sudo, swaylock authentication
- **Auto-Rotation**: Accelerometer-based screen orientation
- **Audio**: EasyEffects with Meze_109_Pro preset
- **Security**: KeePassXC auto-start for secret management
- **Development**: Auto-commit to GitHub on rebuild
- **Thermal**: Thermald protection for critical temperatures

#### ⚠️ Known Issues
- **Hyprgrass**: Only 3-finger gestures work (2/4-finger not responding)
- **Power Management**: TLP disabled due to power-profiles-daemon conflicts
- **Hardware Monitoring**: Disabled due to permission conflicts
- **Home Manager**: Service may show failed status but configuration applies
- **Fusuma**: Disabled due to Ruby gem installation failures in Nix

### Hardware Testing Commands

```bash
# Display & Touch
hyprctl monitors                                      # Check monitor setup
sudo libinput debug-events --device /dev/input/event18  # Monitor touchscreen
cat /sys/bus/iio/devices/iio:device0/in_accel_*_raw   # Test accelerometer

# Fingerprint & Thermal
systemctl status fprintd                             # Check fingerprint service
fprintd-enroll                                       # Enroll fingerprint
cat /sys/class/thermal/thermal_zone0/temp            # Check CPU temperature
systemctl status thermald                            # Monitor thermal daemon

# Gestures & Services
hyprctl plugins list                                 # Check hyprgrass plugin
journalctl -u fix-hyprland-monitor -f               # Monitor rotation service
```

## Development Workflow

### Making Configuration Changes
1. Edit relevant module file (use `sudo` for files in `/nix-modules/`)
2. Test with: `sudo nixos-rebuild test --flake .#hydenix --impure` (or `.#mini`)
3. Apply permanently: `sudo nixos-rebuild switch --flake .#hydenix --impure` (or `.#mini`)
4. Changes auto-commit to GitHub (or use `update!`)
5. If issues occur: `sudo nixos-rebuild switch --rollback`

### Adding New Modules
1. Create `.nix` file in appropriate directory:
   - System-wide: `modules/system/`
   - User-specific: `modules/hm/`
2. Define options under correct namespace:
   - System: `custom.system.myfeature`
   - User: `custom.hm.myfeature`
3. Import in parent `default.nix`
4. Enable in respective `default.nix` or configuration

### Package Management
- **System packages**: Add to `environment.systemPackages` in `modules/system/default.nix:126`
- **User packages**: Add to `home.packages` in `modules/hm/default.nix:122`
- **Custom derivations**: Create in `modules/system/packages/` (see superclaude.nix example)

### Testing and Validation

**Standard Validation Commands**:
```bash
# Validate configuration syntax
nix flake check

# Test build without switching
sudo nixos-rebuild test --flake .#hydenix --impure

# Dry-run to see what would change
sudo nixos-rebuild dry-build --flake .#hydenix --impure

# Build and compare with current system
nixos-rebuild build --flake .#hydenix --impure && nvd diff /run/current-system result
```

**SuperClaude Enhanced Validation Workflows**:
```bash
# For complex system changes, use TodoWrite and agent delegation:
# 1. Create todos for parallel validation tasks:
#    - Hardware compatibility check
#    - Service configuration validation
#    - Module dependency verification
#    - Configuration syntax validation
# 2. Delegate each validation to parallel agents
# 3. Cross-validate results for consistency

# Example parallel validation pattern:
# TodoWrite: [
#   "Validate flake syntax and dependencies",
#   "Test hardware module configurations",
#   "Verify service integration",
#   "Check module namespace consistency"
# ]
# Each todo delegated to specialized agent for parallel execution
```

## SuperClaude Task Management Integration

### Complex Configuration Management

**TodoWrite Patterns for NixOS Development**:
- **Multi-Module Changes**: Break large configuration updates into tracked, parallel tasks
- **Hardware Integration**: Delegate hardware testing to specialized agents
- **Service Validation**: Parallel verification of system services and dependencies
- **Cross-Agent Validation**: Use redundant agent execution for critical system changes

**Task Delegation Examples**:

**Example 1: New Module Development**
```
TodoWrite: [
  "Create module structure in modules/system/newfeature/",
  "Define module options with custom.system.newfeature namespace",
  "Add imports to modules/system/default.nix",
  "Test module configuration with nixos-rebuild test",
  "Validate module integration with existing services"
]
# Delegate tasks 1-3 to Agent A1, task 4 to Agent A2, task 5 to Agent A3
# Cross-validate results across all agents for consistency
```

**Example 2: Hardware Issue Diagnosis**
```
TodoWrite: [
  "Test fingerprint authentication service",
  "Verify touchscreen gesture functionality",
  "Check auto-rotation service status",
  "Validate power management configuration",
  "Confirm thermal management setup"
]
# Each todo delegated to separate agent for parallel hardware testing
# Results cross-validated for comprehensive system health assessment
```

**Example 3: System Recovery Operations**
```
TodoWrite: [
  "Analyze system errors and failure patterns",
  "Check git repository status and integrity",
  "Validate hardware configuration compatibility",
  "Test critical services functionality",
  "Verify NixOS generation status"
]
# Parallel agent execution for comprehensive system diagnosis
# Triple redundancy validation for critical recovery decisions
```

### Framework Integration with .todo File

The repository maintains a persistent `.todo` file for tracking complex operations:
- **Agent Results**: All delegated task results documented with timestamps
- **Cross-Validation**: Multiple agent findings compared for consistency
- **Session Persistence**: Task state maintained across Claude Code sessions
- **Recovery Tracking**: System recovery operations fully documented

**Todo File Management**:
- Never delete todos - save progress to `.todo` file in nix-modules/
- Mark progress as tasks complete with agent attribution
- Use parallel agent execution rather than sequential processing
- Document agent redundancy results for critical system operations

## Important Implementation Details

### Hardware Detection (CRITICAL)
- **Always use `--impure` flag** for nixos-rebuild commands
- Hardware configuration uses smart detection via `hardware-config.nix:10-13`
- Falls back to placeholder when `/etc/nixos/hardware-configuration.nix` unavailable
- This allows GitHub sync without breaking local hardware config

### Auto-commit System
- Runs pre-activation before each rebuild (`modules/system/auto-commit.nix:6-46`)
- Commits all changes with timestamp
- Pushes to GitHub using `gh` CLI
- Prevents "dirty git tree" warnings during flake evaluation

### Module Option Patterns
System modules typically follow:
```nix
custom.system.feature = {
  enable = true;
  option1 = value;
};
```

Home Manager modules follow:
```nix
custom.hm.feature = {
  enable = true;
  option1 = value;
};
```

### Critical Files Reference
- `configuration.nix:75,87,89,103-105` - User setup and system identity
- `modules/system/default.nix:20-103` - All system module toggles
- `modules/hm/default.nix:13-84` - All user module toggles
- `hardware-config.nix:10-13` - Hardware detection logic
- `modules/system/update-alias.nix:6-46` - Quick command definitions
- `flake.nix:47-48` - Flake inputs and nixosConfiguration

## Tips and Warnings

### DO's
- ✅ Always rebuild with `--impure` flag
- ✅ Use `update!` for quick commits and rebuilds
- ✅ Check `journalctl -xe --user` when services fail
- ✅ Use `panic` or `A!` to quickly reset to GitHub state
- ✅ Use `sudo` when modifying files in `/nix-modules/`
- ✅ Follow RULES.md for task management and delegation
- ✅ Create todos for complex tasks (>3 steps) and delegate in parallel
- ✅ Use proper module namespaces (`custom.system.*` or `custom.hm.*`)
- ✅ **SuperClaude**: Use TodoWrite for multi-step NixOS configurations
- ✅ **SuperClaude**: Delegate hardware tests to parallel agents for redundancy
- ✅ **SuperClaude**: Cross-validate critical system changes across multiple agents
- ✅ **SuperClaude**: Document agent results in .todo file for session persistence
- ✅ **SuperClaude**: Use Sequential MCP for complex system analysis
- ✅ **SuperClaude**: Apply Morphllm MCP for bulk configuration changes

### DON'Ts
- ❌ Never rebuild without `--impure` (breaks hardware detection)
- ❌ Don't commit secrets (will be world-readable in Nix store)
- ❌ Don't modify hardware-configuration.nix directly (use hardware-config.nix wrapper)
- ❌ Don't start waybar manually in exec-once (managed by HyDE)
- ❌ Don't forget to use sudo for system-level file edits
- ❌ Don't work on production branch directly (per RULES.md git workflow)
- ❌ Don't ignore module aggregation patterns in default.nix files
- ❌ **SuperClaude**: Don't delete todos from .todo file (save progress instead)
- ❌ **SuperClaude**: Don't execute tasks sequentially when parallel delegation is possible
- ❌ **SuperClaude**: Don't skip agent cross-validation for critical system changes
- ❌ **SuperClaude**: Don't ignore RULES.md behavioral patterns for task management

## Quick Reference

### SuperClaude Framework Quick Patterns

**Multi-Agent Hardware Testing**:
```bash
# Pattern for comprehensive hardware validation
TodoWrite: ["Test fingerprint service", "Check gesture support", "Verify thermal management"]
# → Delegate each todo to Agent A1, A2, A3 for parallel execution
# → Cross-validate results for redundancy and consistency
```

**Complex Module Development**:
```bash
# Pattern for new module creation with validation
TodoWrite: ["Create module structure", "Define options", "Add imports", "Test integration"]
# → Use Sequential MCP for architectural planning
# → Delegate implementation tasks to parallel agents
# → Cross-validate module integration across agents
```

**System Recovery with Agent Redundancy**:
```bash
# Pattern for comprehensive system diagnosis
TodoWrite: ["Analyze errors", "Check git status", "Validate config", "Test services"]
# → Use 3+ agents for each critical task
# → Compare results across agents for consensus
# → Document findings in .todo file for persistence
```

**Bulk Configuration Changes**:
```bash
# Pattern for large-scale configuration updates
# → Use Morphllm MCP for consistent pattern application
# → Sequential MCP for change impact analysis
# → TodoWrite for tracking multi-file modifications
# → Agent delegation for parallel validation
```

### Emergency Recovery
```bash
# PANIC MODE - reset to GitHub state
panic  # or A!, AA!, AAA! (up to 20 A's)

# Rollback to previous working generation
sudo nixos-rebuild switch --rollback

# Check what broke
journalctl -b -p err
```

### Module Development Pattern
1. Create module in appropriate directory (`modules/system/` or `modules/hm/`)
2. Define options under correct namespace (`custom.system.*` or `custom.hm.*`)
3. Add to parent `default.nix` imports
4. Enable in configuration with `enable = true;`
5. Test with `sudo nixos-rebuild test --flake .#hydenix --impure`
6. Apply with `sudo nixos-rebuild switch --flake .#hydenix --impure`